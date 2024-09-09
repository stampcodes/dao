import { expect } from "chai";
import { parseUnits } from "ethers";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";

describe("DAO Contract", function () {
  async function deployDAOFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const ERC20Mock = await ethers.getContractFactory("ERC20Mock");
    const token = await ERC20Mock.deploy(
      "TestToken",
      "TT",
      owner.address,
      parseUnits("1000", 18)
    );

    await token.waitForDeployment();
    console.log("Token Address: ", await token.getAddress());

    const DAO = await ethers.getContractFactory("DAO");
    const dao = await DAO.deploy(await token.getAddress(), 0);
    await dao.waitForDeployment();
    console.log("DAO Address: ", await dao.getAddress());

    return { dao, token, owner, addr1, addr2 };
  }

  it("Should allow users to buy shares and become members", async function () {
    const { dao, token, owner, addr1 } = await loadFixture(deployDAOFixture);

    await dao.connect(owner).addShares(1000);

    await token.transfer(addr1.address, parseUnits("100", 18));
    await token
      .connect(addr1)
      .approve(await dao.getAddress(), parseUnits("100", 18));

    await dao.connect(owner).addMember(addr1.address);

    await dao.connect(addr1).buyShares(parseUnits("100", 18));

    const sharesOwned = await dao.shares(addr1.address);
    const expectedShares =
      BigInt(parseUnits("100", 18).toString()) /
      BigInt(parseUnits("0.01", 18).toString());

    expect(sharesOwned).to.equal(expectedShares);
    expect(await dao.isMemberOrAdmin(addr1.address)).to.equal(true);
  });

  it("Should allow proposals to be added", async function () {
    const { dao, owner } = await loadFixture(deployDAOFixture);

    await dao.connect(owner).addProposal(1, "New proposal");

    const proposal = await dao.proposals(1);
    expect(proposal.whoMadeTheProposal).to.equal(owner.address);
  });

  it("Should allow voting on proposals with weighted votes", async function () {
    const { dao, owner, addr1 } = await loadFixture(deployDAOFixture);

    await dao.addMember(addr1.address);
    await dao.giveShares(addr1.address, 100);
    await dao.giveShares(owner.address, 100);

    await dao.connect(owner).addProposal(1, "Proposal");

    await dao.connect(owner).vote(1, true);
    await dao.connect(addr1).vote(1, false);

    const result = await dao.result(1);
    expect(result[0]).to.equal(2);
    expect(result[2]).to.equal(1);
    expect(result[3]).to.equal(1);
  });

  it("Should not allow voting if no shares are held", async function () {
    const { dao, owner, addr2 } = await loadFixture(deployDAOFixture);

    await dao.connect(owner).addProposal(1, "Proposal");

    await dao.addMember(addr2.address);

    await expect(dao.connect(addr2).vote(1, true)).to.be.revertedWith(
      "You have no shares to vote with."
    );
  });

  it("Should approve proposal with majority votes", async function () {
    const { dao, owner, addr1 } = await loadFixture(deployDAOFixture);

    await dao.addMember(addr1.address);
    await dao.giveShares(addr1.address, 100);
    await dao.giveShares(owner.address, 100);

    await dao.connect(owner).addProposal(1, "Proposal");

    await dao.connect(owner).vote(1, true);
    await dao.connect(addr1).vote(1, true);

    const isApproved = await dao.isProposalApproved(1);
    expect(isApproved).to.equal(true);
  });

  it("Should maintain correct proposal and voting records", async function () {
    const { dao, owner } = await loadFixture(deployDAOFixture);
    await dao.connect(owner).addProposal(1, "Proposal");

    const proposal = await dao.proposals(1);
    expect(proposal.description).to.equal("Proposal");
  });

  it("Should not allow voting without DAO shares", async function () {
    const { dao, owner, addr2 } = await loadFixture(deployDAOFixture);

    await dao.connect(owner).addProposal(1, "Proposal");

    await dao.addMember(addr2.address);

    await expect(dao.connect(addr2).vote(1, true)).to.be.revertedWith(
      "You have no shares to vote with."
    );
  });
});
