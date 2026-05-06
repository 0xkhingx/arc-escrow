// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Escrow.sol";

contract DeployEscrowFactory is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        EscrowFactory factory = new EscrowFactory();

        vm.stopBroadcast();

        console.log("EscrowFactory deployed at:", address(factory));
    }
}
