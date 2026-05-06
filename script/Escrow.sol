// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Escrow.sol";

contract DeployEscrow is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy with a dummy agent address and condition hash for now
        Escrow escrow = new Escrow(
            address(0xdead),
            keccak256("test deployment")
        );

        vm.stopBroadcast();

        console.log("Escrow deployed at:", address(escrow));
    }
}
