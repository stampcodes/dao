// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAO {
    enum Role {
        None,
        Member,
        Admin
    }

    struct RoleData {
        mapping(address => Role) roles;
    }

    // Struttura per le proposte
    struct Proposal {
        address whoMadeTheProposal;
        string description;
        uint count;
        uint proCount;
        uint againstCount;
        uint weightedVoteCount;
        uint weightedProCount;
        uint weightedAgainstCount;
        mapping(address => address) delegatedVote;
        mapping(address => bool) hasVoted;
        uint deadline;
    }

    uint public totalShares = 10000;
    uint public maxShares = 100000;
    uint public sharePrice = 0.01 ether;
    bool public saleActive = true;
    mapping(address => uint) public shares;
    address public admin;

    RoleData private roles;
    mapping(uint => Proposal) public proposals;

    enum GovernanceType {
        Direct,
        Liquid
    }
    GovernanceType public governanceType;

    event SharesBought(address buyer, uint amount);
    event Voted(address voter, uint proposalId, bool voteFor);
    event ProposalCreated(uint proposalId, string description);

    IERC20 public token;

    constructor(address tokenAddress, GovernanceType _governanceType) {
        token = IERC20(tokenAddress);
        governanceType = _governanceType;
        roles.roles[msg.sender] = Role.Admin;
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "You are not the Admin");
        _;
    }

    modifier onlyMemberOrHigher() {
        require(
            isMemberOrAdmin(msg.sender),
            "You do not have the correct role"
        );
        _;
    }

    modifier idNotRegistered(uint proposalId) {
        require(
            proposals[proposalId].whoMadeTheProposal == address(0),
            "The Id is already taken"
        );
        _;
    }

    modifier idRegistered(uint proposalId) {
        require(
            proposals[proposalId].whoMadeTheProposal != address(0),
            "The Id doesn't exist"
        );
        _;
    }

    modifier saleIsActive() {
        require(saleActive == true, "Sale is not active");
        _;
    }

    function addMember(address newMember) public onlyAdmin {
        roles.roles[newMember] = Role.Member;
    }

    function removeMember(address removedMember) public onlyAdmin {
        roles.roles[removedMember] = Role.None;
    }

    function isAdmin(address user) public view returns (bool) {
        return roles.roles[user] == Role.Admin;
    }

    function isMemberOrAdmin(address user) public view returns (bool) {
        return
            roles.roles[user] == Role.Member || roles.roles[user] == Role.Admin;
    }

    function toggleSaleStatus() public onlyAdmin {
        saleActive = !saleActive;
    }

    function buyShares(uint amountOfTokens) public saleIsActive {
        require(amountOfTokens > 0, "You must send tokens to buy shares.");
        uint sharesToBuy = amountOfTokens / sharePrice;
        require(sharesToBuy <= totalShares, "Not enough shares available.");

        token.transferFrom(msg.sender, address(this), amountOfTokens);
        shares[msg.sender] += sharesToBuy;
        totalShares -= sharesToBuy;

        if (roles.roles[msg.sender] == Role.None) {
            addMember(msg.sender);
        }

        emit SharesBought(msg.sender, sharesToBuy);
    }

    function withdrawTokens() public onlyAdmin {
        uint balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        token.transfer(admin, balance);
    }

    function addShares(uint howManyShares) public onlyAdmin {
        require(
            totalShares + howManyShares <= maxShares,
            "Cannot exceed max shares limit"
        );
        totalShares += howManyShares;
    }

    function removeShares(uint howManyShares) public onlyAdmin {
        totalShares -= howManyShares;
    }

    function giveShares(
        address userAddress,
        uint amountOfShares
    ) public onlyAdmin {
        require(totalShares > 0, "No shares available");
        require(amountOfShares <= totalShares, "Not enough shares available");
        shares[userAddress] += amountOfShares;
        totalShares -= amountOfShares;
    }

    function delegateVote(
        uint proposalId,
        address _delegate
    ) public onlyMemberOrHigher {
        require(
            governanceType == GovernanceType.Liquid,
            "Delegation only allowed in liquid democracy"
        );
        proposals[proposalId].delegatedVote[msg.sender] = _delegate;
    }

    function addProposal(
        uint proposalId,
        string memory description
    ) public onlyMemberOrHigher idNotRegistered(proposalId) {
        Proposal storage newProposal = proposals[proposalId];
        newProposal.whoMadeTheProposal = msg.sender;
        newProposal.description = description;
        newProposal.deadline = block.timestamp + (1 days);
        emit ProposalCreated(proposalId, description);
    }

    function vote(
        uint proposalId,
        bool voteFor
    ) public onlyMemberOrHigher idRegistered(proposalId) {
        require(
            !proposals[proposalId].hasVoted[msg.sender],
            "You have already voted."
        );
        require(shares[msg.sender] > 0, "You have no shares to vote with.");
        Proposal storage proposal = proposals[proposalId];
        proposal.hasVoted[msg.sender] = true;
        proposal.count++;
        proposal.weightedVoteCount += shares[msg.sender];
        if (voteFor) {
            proposal.proCount++;
            proposal.weightedProCount += shares[msg.sender];
        } else {
            proposal.againstCount++;
            proposal.weightedAgainstCount += shares[msg.sender];
        }
        emit Voted(msg.sender, proposalId, voteFor);
    }

    function isProposalApproved(uint proposalId) public view returns (bool) {
        Proposal storage proposal = proposals[proposalId];
        return proposal.weightedProCount > proposal.weightedAgainstCount;
    }

    function closeProposal(uint proposalId) public onlyAdmin {
        require(
            block.timestamp >= proposals[proposalId].deadline,
            "Proposal is still active"
        );
        delete proposals[proposalId];
    }

    function result(
        uint proposalId
    ) public view returns (uint, uint, uint, uint) {
        Proposal storage proposal = proposals[proposalId];
        return (
            proposal.count,
            proposal.weightedVoteCount,
            proposal.proCount,
            proposal.againstCount
        );
    }
}
