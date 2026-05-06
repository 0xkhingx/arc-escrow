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

contract Escrow {
    address public constant USDC = 0x3600000000000000000000000000000000000000;

    address public payer;
    address public agent;
    uint256 public amount;
    bytes32 public conditionHash;

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

    constructor(address _agent, bytes32 _conditionHash) {
        payer = msg.sender;
        agent = _agent;
        conditionHash = _conditionHash;
        currentState = State.AWAITING_PAYMENT;
    }

    function deposit(
        uint256 _amount
    ) external onlyPayer inState(State.AWAITING_PAYMENT) {
        require(_amount > 0, "Amount must be > 0");
        IERC20(USDC).transferFrom(msg.sender, address(this), _amount);
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
        IERC20(USDC).transfer(agent, amount);
        emit Completed(agent, amount);
    }

    function dispute() external onlyPayer inState(State.AWAITING_COMPLETION) {
        currentState = State.DISPUTED;
        emit Disputed(msg.sender);
    }

    function refund() external onlyPayer inState(State.DISPUTED) {
        currentState = State.REFUNDED;
        IERC20(USDC).transfer(payer, amount);
        emit Refunded(payer, amount);
    }
}
