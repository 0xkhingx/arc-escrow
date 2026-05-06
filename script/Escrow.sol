// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Escrow} from "../src/Escrow.sol";

contract EscrowScript is Script {
    Escrow public escrow;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        escrow = new Escrow(address(2), keccak256("complete the task"));

        vm.stopBroadcast();
    }
}
