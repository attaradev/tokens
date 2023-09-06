import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

async function deployW3BTokenFixture() {
  const [admin, ...addresses] = await ethers.getSigners();
  const W3BToken = await ethers.getContractFactory("W3BToken");
  const w3BToken = await W3BToken.deploy();
  return {
    w3BToken,
    admin,
    addresses,
  };
}

describe("W3BToken", function () {
  describe("Minting", function () {
    it("Should allow only admin to mint tokens", async function () {
      const { w3BToken, admin, addresses } = await loadFixture(
        deployW3BTokenFixture
      );
      const [address1] = addresses;
      await w3BToken.mint(address1.address, 5);
      expect(await w3BToken.balanceOf(address1.address)).to.equal(5);
      await expect(
        w3BToken.connect(address1).mint(address1.address, 5)
      ).to.be.revertedWith("W3B Token: caller is not the administrator");
    });
  });
});
