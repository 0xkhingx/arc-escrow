// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/AgentRegistry.sol";

contract AgentRegistryTest is Test {
    AgentRegistry public registry;

    address owner = address(0x1234);
    address factory = address(0x5678);
    address agent1 = address(0xAAAA);
    address agent2 = address(0xBBBB);

    function setUp() public {
        vm.prank(owner);
        registry = new AgentRegistry(factory);
    }

    function test_Register() public {
        vm.prank(agent1);
        registry.register(
            "Agent Alpha",
            "I process invoices and data pipelines",
            "Data"
        );

        AgentRegistry.Agent memory a = registry.getAgent(agent1);
        assertEq(a.name, "Agent Alpha");
        assertEq(a.isActive, true);
        assertEq(a.completedJobs, 0);
    }

    function test_CannotRegisterTwice() public {
        vm.prank(agent1);
        registry.register("Agent Alpha", "Data pipelines", "Data");

        vm.prank(agent1);
        vm.expectRevert("Already registered");
        registry.register("Agent Alpha Again", "Duplicate", "Data");
    }

    function test_RecordCompletion() public {
        vm.prank(agent1);
        registry.register("Agent Alpha", "Data pipelines", "Data");

        vm.prank(factory);
        registry.recordCompletion(agent1, 500_000_000); // 500 USDC (6 decimals)

        AgentRegistry.Agent memory a = registry.getAgent(agent1);
        assertEq(a.completedJobs, 1);
        assertEq(a.totalUSDCSettled, 500_000_000);
    }

    function test_ReputationScore() public {
        vm.prank(agent1);
        registry.register("Agent Alpha", "Data pipelines", "Data");

        vm.prank(factory);
        registry.recordCompletion(agent1, 1000_000_000); // 1000 USDC

        uint256 rep = registry.getReputation(agent1);
        // (1 * 10) + (1000_000_000 / 100) = 10 + 10_000_000 = 10_000_010
        assertEq(rep, 10_000_010);
    }

    function test_OnlyFactoryCanRecordCompletion() public {
        vm.prank(agent1);
        registry.register("Agent Alpha", "Data pipelines", "Data");

        vm.prank(agent2); // not the factory
        vm.expectRevert("Not authorized");
        registry.recordCompletion(agent1, 100_000_000);
    }

    function test_RecordDispute() public {
        vm.prank(agent1);
        registry.register("Agent Alpha", "Data pipelines", "Data");

        vm.prank(factory);
        registry.recordDispute(agent1);

        AgentRegistry.Agent memory a = registry.getAgent(agent1);
        assertEq(a.disputedJobs, 1);
    }

    function test_Deactivate() public {
        vm.prank(agent1);
        registry.register("Agent Alpha", "Data pipelines", "Data");

        vm.prank(agent1);
        registry.deactivate();

        AgentRegistry.Agent memory a = registry.getAgent(agent1);
        assertEq(a.isActive, false);
        assertEq(registry.getReputation(agent1), 0);
    }

    function test_GetAgents() public {
        vm.prank(agent1);
        registry.register("Agent Alpha", "Data pipelines", "Data");

        vm.prank(agent2);
        registry.register("Agent Beta", "Code review and audits", "Security");

        AgentRegistry.Agent[] memory list = registry.getAgents(0, 2);
        assertEq(list.length, 2);
        assertEq(list[0].name, "Agent Alpha");
        assertEq(list[1].name, "Agent Beta");
    }

    function test_OnlyOwnerCanUpdateFactory() public {
        vm.prank(agent1);
        vm.expectRevert("Not owner");
        registry.updateFactory(address(0x9999));

        vm.prank(owner);
        registry.updateFactory(address(0x9999));
        assertEq(registry.authorized(address(0x9999)), true);
    }
}
