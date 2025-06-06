// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC20Token.sol"; // Assuming WLDToken is an ERC20Token

contract WLDVotingDAO {
    struct Proposal {
        uint256 id;
        string description;
        uint256 snapshotBlock;
        uint256 voteCountYes;
        uint256 voteCountNo;
        mapping(address => bool) hasVoted;
        bool open;
        bool finalized;
        bool passed;
    }

    ERC20Token public wldToken;
    uint256 public nextProposalId;
    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 id, string description, uint256 snapshotBlock);
    event Voted(uint256 proposalId, address voter, bool support, uint256 votingPower);
    event ProposalFinalized(uint256 id, bool passed);

    constructor(address _wldTokenAddress) {
        wldToken = ERC20Token(_wldTokenAddress);
        nextProposalId = 1;
    }

    function createProposal(string memory _description, uint256 _snapshotBlock) public returns (uint256) {
        require(_snapshotBlock < block.number, "Snapshot block must be in the past");

        uint256 proposalId = nextProposalId;
        proposals[proposalId].id = proposalId;
        proposals[proposalId].description = _description;
        proposals[proposalId].snapshotBlock = _snapshotBlock;
        proposals[proposalId].open = true;
        proposals[proposalId].finalized = false;
        proposals[proposalId].voteCountYes = 0;
        proposals[proposalId].voteCountNo = 0;

        nextProposalId++;

        emit ProposalCreated(proposalId, _description, _snapshotBlock);
        return proposalId;
    }

    function getVotingPower(address _voter, uint256 _snapshotBlock) public view returns (uint256) {
        // This is a simplified way to get balance at a past block.
        // In a real scenario, you would need a more robust solution like Chainlink historical data or a custom snapshot mechanism.
        // For this example, we'll assume the ERC20Token contract has a way to query past balances or that the current balance is sufficient for demonstration.
        // A more accurate implementation would involve iterating through past Transfer events or using a specialized snapshot library.
        return wldToken.balanceOf(_voter);
    }

    function vote(uint256 _proposalId, bool _support) public {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(proposal.open, "Proposal is not open for voting");
        require(!proposal.hasVoted[msg.sender], "Already voted on this proposal");

        uint256 votingPower = getVotingPower(msg.sender, proposal.snapshotBlock);
        require(votingPower > 0, "No voting power");

        if (_support) {
            proposal.voteCountYes += votingPower;
        } else {
            proposal.voteCountNo += votingPower;
        }

        proposal.hasVoted[msg.sender] = true;

        emit Voted(_proposalId, msg.sender, _support, votingPower);
    }

    function finalizeProposal(uint256 _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(proposal.open, "Proposal is still open");
        require(!proposal.finalized, "Proposal already finalized");

        proposal.open = false;
        proposal.finalized = true;
        proposal.passed = proposal.voteCountYes > proposal.voteCountNo;

        emit ProposalFinalized(_proposalId, proposal.passed);
    }

    function getProposalResult(uint256 _proposalId) public view returns (bool, uint256, uint256) {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(proposal.finalized, "Proposal not yet finalized");
        return (proposal.passed, proposal.voteCountYes, proposal.voteCountNo);
    }
}