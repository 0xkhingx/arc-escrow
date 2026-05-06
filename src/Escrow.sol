// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Escrow {
    // --- State Variables ---
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

    // --- Events ---
    event Deposited(address indexed payer, uint256 amount);
    event Completed(address indexed agent, uint256 amount);
    event Disputed(address indexed payer);
    event Refunded(address indexed payer, uint256 amount);

    // --- Modifiers ---
    modifier onlyPayer() {
        require(msg.sender == payer, "Only payer can call this");
        _;
    }

    modifier onlyAgent() {
        require(msg.sender == agent, "Only agent can call this");
        _;
    }

    modifier inState(State expected) {
        require(currentState == expected, "Invalid state");
        _;
    }

    // --- Constructor ---
    constructor(address _agent, bytes32 _conditionHash) {
        payer = msg.sender;
        agent = _agent;
        conditionHash = _conditionHash;
        currentState = State.AWAITING_PAYMENT;
    }

    // --- Functions ---
    function deposit()
        external
        payable
        onlyPayer
        inState(State.AWAITING_PAYMENT)
    {
        amount = msg.value;
        currentState = State.AWAITING_COMPLETION;
        emit Deposited(msg.sender, msg.value);
    }

    function confirmCompletion()
        external
        onlyPayer
        inState(State.AWAITING_COMPLETION)
    {
        currentState = State.COMPLETE;
        payable(agent).transfer(amount);
        emit Completed(agent, amount);
    }

    function dispute() external onlyPayer inState(State.AWAITING_COMPLETION) {
        currentState = State.DISPUTED;
        emit Disputed(msg.sender);
    }

    function refund() external onlyPayer inState(State.DISPUTED) {
        currentState = State.REFUNDED;
        payable(payer).transfer(amount);
        emit Refunded(payer, amount);
    }
}
