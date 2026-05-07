// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Escrow.sol";
import "../src/AgentRegistry.sol";

contract DeployAll is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy factory
        EscrowFactory factory = new EscrowFactory();
        console.log("EscrowFactory deployed at:", address(factory));

        // Deploy registry with factory address
        AgentRegistry registry = new AgentRegistry(address(factory));
        console.log("AgentRegistry deployed at:", address(registry));

        // Wire them together — factory now knows the registry
        factory.setRegistry(address(registry));
        console.log("Registry wired to factory");

        vm.stopBroadcast();
    }
}
