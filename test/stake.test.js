const { expect } = require("chai")
const { ethers, deployments } = require("hardhat")

const day = 24 * 60 * 60

describe("Stake", function () {
  before(async function () {
    this.signers = await ethers.getSigners()
    this.deployer = this.signers[0]
    this.first = this.signers[1]
    this.second = this.signers[2]
    this.three = this.signers[3]
  })
  beforeEach(async function () {
    await deployments.fixture()
    this.stake = await ethers.getContract("Stake")
    this.BPT = await ethers.getContract("BPT")
    this.reward = await ethers.getContract("reward")
    //await this.reward.mint(this.deployer.address,3000)
    //await this.reward.approve(this.stake.address,3000)
    //await this.stake.depositRewards(3000)
  })
  it("initial params")
  describe("wait 5 days and first deposit", function () {
    beforeEach(async function () {
      await ethers.provider.send("evm_increaseTime", [5.5 * day])
      await this.BPT.mint(this.first.address, 5)
      await this.BPT.connect(this.first).approve(this.stake.address, 5)
      await this.stake.connect(this.first).deposit(5)
    })
    describe("wait 5 days and second deposit", function () {
      beforeEach(async function () {
        await ethers.provider.send("evm_increaseTime", [5 * day])
        await this.BPT.mint(this.second.address, 15)
        await this.BPT.connect(this.second).approve(this.stake.address, 15)
        await this.stake.connect(this.second).deposit(15)
      })

      describe("wait 5 days and withdraw all", function () {
        beforeEach(async function () {
          await ethers.provider.send("evm_increaseTime", [5.1 * day])
          await this.stake.connect(this.first).withdrawBPT(5)
          await this.stake.connect(this.second).withdrawBPT(15)
        })
        describe("wait 5 days and first, second, three deposit", function () {
          beforeEach(async function () {
            await ethers.provider.send("evm_increaseTime", [5.1 * day])
            await this.BPT.mint(this.three.address, 20)
            await this.BPT.connect(this.three).approve(this.stake.address, 20)
            await this.stake.connect(this.three).deposit(20)
            await this.BPT.connect(this.second).approve(this.stake.address, 15)
            await this.stake.connect(this.second).deposit(15)
            await this.BPT.connect(this.first).approve(this.stake.address, 5)
            await this.stake.connect(this.first).deposit(5)
            // add reward
            await this.reward.mint(this.deployer.address, 30000)
            await this.reward.approve(this.stake.address, 30000)
            await this.stake.depositRewards(30000)
          })
          describe("wait 10+days(finished stake) ", function () {
            beforeEach(async function () {
              await ethers.provider.send("evm_increaseTime", [11 * day])
            })
            it("withdraw reward", async function () {
              await this.stake.connect(this.first).withdrawRewards()
              await this.stake.connect(this.second).withdrawRewards()
              await this.stake.connect(this.three).withdrawRewards()

              await this.stake.withdrawUnusedRewards()
              expect(await this.reward.balanceOf(this.first.address)).to.be.equal(7500)
              expect(await this.reward.balanceOf(this.second.address)).to.be.equal(7500)
              expect(await this.reward.balanceOf(this.three.address)).to.be.equal(5000)
              expect(await this.reward.balanceOf(this.deployer.address)).to.be.equal(10000)
            })
          })
        })
      })
    })
  })
})
