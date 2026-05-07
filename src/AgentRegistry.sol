// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AgentRegistry {
    struct Agent {
        address wallet;
        string name;
        string description;
        string serviceType;
        uint256 completedJobs;
        uint256 disputedJobs;
        uint256 totalUSDCSettled;
        uint256 registeredAt;
        bool isActive;
    }

    mapping(address => Agent) public agents;
    address[] public agentList;

    // Authorized callers (escrow contracts) can update reputation
    mapping(address => bool) public authorized;
    address public owner;

    event AgentRegistered(
        address indexed wallet,
        string name,
        string serviceType
    );
    event ReputationUpdated(
        address indexed agent,
        uint256 completedJobs,
        uint256 totalUSDCSettled
    );
    event AgentDeactivated(address indexed wallet);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyFactory() {
        require(authorized[msg.sender], "Not authorized");
        _;
    }

    constructor(address _escrowFactory) {
        owner = msg.sender;
        authorized[_escrowFactory] = true;
    }

    function authorize(address _addr) external onlyFactory {
        authorized[_addr] = true;
    }

    function revoke(address _addr) external onlyOwner {
        authorized[_addr] = false;
    }

    function register(
        string calldata _name,
        string calldata _description,
        string calldata _serviceType
    ) external {
        require(bytes(_name).length > 0, "Name required");
        require(!agents[msg.sender].isActive, "Already registered");

        agents[msg.sender] = Agent({
            wallet: msg.sender,
            name: _name,
            description: _description,
            serviceType: _serviceType,
            completedJobs: 0,
            disputedJobs: 0,
            totalUSDCSettled: 0,
            registeredAt: block.timestamp,
            isActive: true
        });

        agentList.push(msg.sender);
        emit AgentRegistered(msg.sender, _name, _serviceType);
    }

    function recordCompletion(
        address _agent,
        uint256 _amount
    ) external onlyFactory {
        require(agents[_agent].isActive, "Agent not registered");
        agents[_agent].completedJobs += 1;
        agents[_agent].totalUSDCSettled += _amount;
        emit ReputationUpdated(
            _agent,
            agents[_agent].completedJobs,
            agents[_agent].totalUSDCSettled
        );
    }

    function recordDispute(address _agent) external onlyFactory {
        require(agents[_agent].isActive, "Agent not registered");
        agents[_agent].disputedJobs += 1;
    }

    function getReputation(address _agent) external view returns (uint256) {
        Agent memory a = agents[_agent];
        if (!a.isActive) return 0;
        return (a.completedJobs * 10) + (a.totalUSDCSettled / 100);
    }

    function getAgentCount() external view returns (uint256) {
        return agentList.length;
    }

    function getAgents(
        uint256 _from,
        uint256 _to
    ) external view returns (Agent[] memory) {
        require(_to <= agentList.length, "Out of range");
        Agent[] memory result = new Agent[](_to - _from);
        for (uint256 i = _from; i < _to; i++) {
            result[i - _from] = agents[agentList[i]];
        }
        return result;
    }

    function deactivate() external {
        require(agents[msg.sender].isActive, "Not registered");
        agents[msg.sender].isActive = false;
        emit AgentDeactivated(msg.sender);
    }

    function updateFactory(address _newFactory) external onlyOwner {
        authorized[_newFactory] = true;
    }

    function getAgent(address _wallet) external view returns (Agent memory) {
        return agents[_wallet];
    }
}
