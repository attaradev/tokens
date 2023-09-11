import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

async function deployMPawaFixture() {
  const [admin, ...addresses] = await ethers.getSigners();
  const MPawa = await ethers.getContractFactory("MPawa");
  const mPawa = await MPawa.deploy();
  return {
    mPawa,
    admin,
    addresses,
  };
}

describe("MPawa", function () {
  describe("Minting", function () {
    it("Should allow only admin to mint tokens", async function () {
      const { mPawa, admin, addresses } = await loadFixture(deployMPawaFixture);
      const [address1] = addresses;
      const value = 1000000000;
      await mPawa.mint(address1.address, "1", value);
      expect(await mPawa.balanceOf(address1.address, 1)).to.equal(value);
      await expect(
        mPawa.connect(address1).mint(address1.address, "1", value)
      ).to.be.revertedWith("ERC1155: caller is not the administrator");
    });
  });
});
