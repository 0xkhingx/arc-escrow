// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Escrow.sol";

// Mock USDC contract for testing
contract MockUSDC {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract EscrowTest is Test {
    Escrow public escrow;
    MockUSDC public usdc;

    address payer = address(0x1234);
    address agent = address(0x5678);
    bytes32 conditionHash = keccak256("complete the task");
    uint256 depositAmount = 1000e6; // 1000 USDC

    function setUp() public {
        // Deploy mock USDC at the Arc system address
        usdc = new MockUSDC();
        vm.etch(0x3600000000000000000000000000000000000000, address(usdc).code);
        usdc = MockUSDC(0x3600000000000000000000000000000000000000);

        // Fund payer and deploy escrow
        usdc.mint(payer, depositAmount);
        vm.prank(payer);
        escrow = new Escrow(agent, conditionHash);
    }

    function test_InitialState() public view {
        assertEq(escrow.payer(), payer);
        assertEq(escrow.agent(), agent);
        assertEq(escrow.conditionHash(), conditionHash);
    }

    function test_Deposit() public {
        vm.startPrank(payer);
        usdc.approve(address(escrow), depositAmount);
        escrow.deposit(depositAmount);
        vm.stopPrank();

        assertEq(escrow.amount(), depositAmount);
        assertEq(usdc.balanceOf(address(escrow)), depositAmount);
    }

    function test_ConfirmCompletion() public {
        vm.startPrank(payer);
        usdc.approve(address(escrow), depositAmount);
        escrow.deposit(depositAmount);
        escrow.confirmCompletion();
        vm.stopPrank();

        assertEq(usdc.balanceOf(agent), depositAmount);
        assertEq(usdc.balanceOf(address(escrow)), 0);
    }

    function test_Dispute() public {
        vm.startPrank(payer);
        usdc.approve(address(escrow), depositAmount);
        escrow.deposit(depositAmount);
        escrow.dispute();
        escrow.refund();
        vm.stopPrank();

        assertEq(usdc.balanceOf(payer), depositAmount);
        assertEq(usdc.balanceOf(address(escrow)), 0);
    }

    function test_OnlyPayerCanDeposit() public {
        usdc.mint(agent, depositAmount);
        vm.startPrank(agent);
        usdc.approve(address(escrow), depositAmount);
        vm.expectRevert("Only payer can call this");
        escrow.deposit(depositAmount);
        vm.stopPrank();
    }
}
