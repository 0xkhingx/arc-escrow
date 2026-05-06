// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Escrow.sol";

contract EscrowTest is Test {
    Escrow public escrow;
    address payer = address(0x1234);
    address agent = address(0x5678);
    address other = address(0x9999);
    bytes32 conditionHash = keccak256("complete the task");
    uint256 depositAmount = 1 ether;

    function setUp() public {
        vm.prank(payer);
        escrow = new Escrow(agent, conditionHash);
    }

    function test_InitialState() public view {
        assertEq(escrow.payer(), payer);
        assertEq(escrow.agent(), agent);
        assertEq(escrow.conditionHash(), conditionHash);
    }

    function test_Deposit() public {
        vm.deal(payer, depositAmount);
        vm.prank(payer);
        escrow.deposit{value: depositAmount}();
        assertEq(escrow.amount(), depositAmount);
        assertEq(address(escrow).balance, depositAmount);
    }

    function test_ConfirmCompletion() public {
        vm.deal(payer, depositAmount);
        vm.prank(payer);
        escrow.deposit{value: depositAmount}();

        vm.prank(payer);
        escrow.confirmCompletion();
        assertEq(address(agent).balance, depositAmount);
        assertEq(address(escrow).balance, 0);
    }

    function test_Dispute() public {
        vm.deal(payer, depositAmount);
        vm.prank(payer);
        escrow.deposit{value: depositAmount}();

        assertEq(address(escrow).balance, depositAmount);

        vm.prank(payer);
        escrow.dispute();

        vm.prank(payer);
        escrow.refund();

        assertEq(address(payer).balance, depositAmount);
        assertEq(address(escrow).balance, 0);
    }

    function test_OnlyPayerCanDeposit() public {
        vm.deal(agent, depositAmount);
        vm.prank(agent);
        vm.expectRevert("Only payer can call this");
        escrow.deposit{value: depositAmount}();
    }
}
