// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/WLDVotingDAO.sol";
import "../src/ERC20Token.sol";

contract WLDVotingDAOTest is Test {
    WLDVotingDAO public dao;
    ERC20Token public wldToken;

    address public deployer;
    address public voter1;
    address public voter2;
    address public voter3;

    function setUp() public {
        deployer = makeAddr("deployer");
        voter1 = makeAddr("voter1");
        voter2 = makeAddr("voter2");
        voter3 = makeAddr("voter3");

        vm.startPrank(deployer);
        wldToken = new ERC20Token("Worldcoin", "WLD", 18, 10000 * 10 ** 18);
        dao = new WLDVotingDAO(address(wldToken));

        // Transfer WLD tokens to voters
        wldToken.transfer(voter1, 1000 * 10 ** 18);
        wldToken.transfer(voter2, 500 * 10 ** 18);
        wldToken.transfer(voter3, 2000 * 10 ** 18);
        vm.stopPrank();
    }

    function testCreateProposal() public {
        uint256 snapshotBlock = block.number - 1;
        vm.prank(deployer);
        uint256 proposalId = dao.createProposal("Test Proposal", snapshotBlock);

        assertEq(proposalId, 1);
        (
            uint256 id,
            string memory description,
            uint256 sBlock,
            uint256 voteYes,
            uint256 voteNo,
            bool open,
            bool finalized,
            bool passed
        ) = dao.proposals(proposalId);
        assertEq(id, 1);
        assertEq(description, "Test Proposal");
        assertEq(sBlock, snapshotBlock);
        assertTrue(open);
        assertFalse(finalized);
        assertFalse(passed);
    }

    function testVote() public {
        uint256 snapshotBlock = block.number - 1;
        vm.prank(deployer);
        uint256 proposalId = dao.createProposal("Vote Test Proposal", snapshotBlock);

        // Simulate moving to the next block for snapshot to be in the past
        vm.roll(block.number + 1);

        // Voter1 votes Yes
        vm.prank(voter1);
        dao.vote(proposalId, true);

        (
            uint256 id,
            string memory description,
            uint256 sBlock,
            uint256 voteYes,
            uint256 voteNo,
            bool open,
            bool finalized,
            bool passed
        ) = dao.proposals(proposalId);
        assertEq(voteYes, 1000 * 10 ** 18); // Voter1's balance
        assertEq(voteNo, 0);

        // Voter2 votes No
        vm.prank(voter2);
        dao.vote(proposalId, false);

        (id, description, sBlock, voteYes, voteNo, open, finalized, passed) = dao.proposals(proposalId);
        assertEq(voteYes, 1000 * 10 ** 18);
        assertEq(voteNo, 500 * 10 ** 18); // Voter2's balance

        // Ensure voter cannot vote twice
        vm.expectRevert("Already voted on this proposal");
        vm.prank(voter1);
        dao.vote(proposalId, true);
    }

    function testFinalizeProposal() public {
        uint256 snapshotBlock = block.number - 1;
        vm.prank(deployer);
        uint256 proposalId = dao.createProposal("Finalize Test Proposal", snapshotBlock);

        vm.roll(block.number + 1);

        vm.prank(voter1);
        dao.vote(proposalId, true); // 1000

        vm.prank(voter2);
        dao.vote(proposalId, false); // 500

        vm.prank(voter3);
        dao.vote(proposalId, true); // 2000

        vm.prank(deployer);
        dao.finalizeProposal(proposalId);

        (bool passed, uint256 voteYes, uint256 voteNo) = dao.getProposalResult(proposalId);
        assertTrue(passed); // 1000 + 2000 (Yes) > 500 (No)
        assertEq(voteYes, 3000 * 10 ** 18);
        assertEq(voteNo, 500 * 10 ** 18);

        // Ensure proposal cannot be voted on after finalization
        vm.expectRevert("Proposal is not open for voting");
        vm.prank(voter1);
        dao.vote(proposalId, true);

        // Ensure proposal cannot be finalized twice
        vm.expectRevert("Proposal already finalized");
        vm.prank(deployer);
        dao.finalizeProposal(proposalId);
    }

    function testGetVotingPower() public view {
        uint256 power1 = dao.getVotingPower(voter1, block.number);
        assertEq(power1, 1000 * 10 ** 18);

        uint256 power2 = dao.getVotingPower(voter2, block.number);
        assertEq(power2, 500 * 10 ** 18);

        uint256 power3 = dao.getVotingPower(voter3, block.number);
        assertEq(power3, 2000 * 10 ** 18);
    }

    function testRevertCreateProposalFutureSnapshot() public {
        vm.expectRevert("Snapshot block must be in the past");
        vm.prank(deployer);
        dao.createProposal("Future Snapshot Proposal", block.number + 1);
    }

    function testRevertVoteNoVotingPower() public {
        uint256 snapshotBlock = block.number - 1;
        vm.prank(deployer);
        uint256 proposalId = dao.createProposal("No Power Proposal", snapshotBlock);

        vm.roll(block.number + 1);

        address noWLDHolder = makeAddr("noWLD");
        vm.expectRevert("No voting power");
        vm.prank(noWLDHolder);
        dao.vote(proposalId, true);
    }
}
