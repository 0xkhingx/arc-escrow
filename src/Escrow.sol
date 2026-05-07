// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);
}

interface IAgentRegistry {
    function recordCompletion(address _agent, uint256 _amount) external;

    function recordDispute(address _agent) external;

    function authorize(address _addr) external;

    function getAgent(
        address _wallet
    )
        external
        view
        returns (
            address wallet,
            string memory name,
            string memory description,
            string memory serviceType,
            uint256 completedJobs,
            uint256 disputedJobs,
            uint256 totalUSDCSettled,
            uint256 registeredAt,
            bool isActive
        );
}

contract Escrow {
    address public constant USDC = 0x3600000000000000000000000000000000000000;

    address public payer;
    address public agent;
    uint256 public amount;
    bytes32 public conditionHash;
    address public registry;

    enum State {
        AWAITING_PAYMENT,
        AWAITING_COMPLETION,
        COMPLETE,
        DISPUTED,
        REFUNDED
    }
    State public currentState;

    event Deposited(address indexed payer, uint256 amount);
    event Completed(address indexed agent, uint256 amount);
    event Disputed(address indexed payer);
    event Refunded(address indexed payer, uint256 amount);

    modifier onlyPayer() {
        require(msg.sender == payer, "Only payer can call this");
        _;
    }

    modifier inState(State expected) {
        require(currentState == expected, "Invalid state");
        _;
    }

    constructor(
        address _payer,
        address _agent,
        bytes32 _conditionHash,
        address _registry
    ) {
        payer = _payer;
        agent = _agent;
        conditionHash = _conditionHash;
        registry = _registry;
        currentState = State.AWAITING_PAYMENT;
    }

    function deposit(
        uint256 _amount
    ) external onlyPayer inState(State.AWAITING_PAYMENT) {
        require(_amount > 0, "Amount must be > 0");
        require(
            IERC20(USDC).transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        amount = _amount;
        currentState = State.AWAITING_COMPLETION;
        emit Deposited(msg.sender, _amount);
    }

    function confirmCompletion()
        external
        onlyPayer
        inState(State.AWAITING_COMPLETION)
    {
        currentState = State.COMPLETE;
        require(IERC20(USDC).transfer(agent, amount), "Transfer failed");
        emit Completed(agent, amount);

        if (registry != address(0)) {
            try
                IAgentRegistry(registry).recordCompletion(agent, amount)
            {} catch {}
        }
    }

    function dispute() external onlyPayer inState(State.AWAITING_COMPLETION) {
        currentState = State.DISPUTED;
        emit Disputed(msg.sender);

        if (registry != address(0)) {
            try IAgentRegistry(registry).recordDispute(agent) {} catch {}
        }
    }

    function refund() external onlyPayer inState(State.DISPUTED) {
        currentState = State.REFUNDED;
        require(IERC20(USDC).transfer(payer, amount), "Transfer failed");
        emit Refunded(payer, amount);
    }
}

contract EscrowFactory {
    address[] public escrows;
    address public registry;
    address public owner;

    event EscrowCreated(
        address indexed escrowAddress,
        address indexed payer,
        address indexed agent,
        bytes32 conditionHash
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setRegistry(address _registry) external onlyOwner {
        registry = _registry;
    }

    function createEscrow(
        address _agent,
        bytes32 _conditionHash
    ) external returns (address) {
        Escrow escrow = new Escrow(
            msg.sender,
            _agent,
            _conditionHash,
            registry
        );
        escrows.push(address(escrow));

        // Authorize the new escrow to call the registry directly
        if (registry != address(0)) {
            IAgentRegistry(registry).authorize(address(escrow));
        }

        emit EscrowCreated(address(escrow), msg.sender, _agent, _conditionHash);
        return address(escrow);
    }

    function getEscrows() external view returns (address[] memory) {
        return escrows;
    }

    function getEscrowCount() external view returns (uint256) {
        return escrows.length;
    }
}
