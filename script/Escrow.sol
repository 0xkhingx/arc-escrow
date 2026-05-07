// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Escrow.sol";
import "../src/AgentRegistry.sol";

contract DeployAll is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy factory first
        EscrowFactory factory = new EscrowFactory();
        console.log("EscrowFactory deployed at:", address(factory));

        // Deploy registry, passing factory address so it can update reputation
        AgentRegistry registry = new AgentRegistry(address(factory));
        console.log("AgentRegistry deployed at:", address(registry));

        vm.stopBroadcast();
    }
}
