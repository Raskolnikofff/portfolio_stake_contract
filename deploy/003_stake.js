module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()

  const BPT = await deployments.get("BPT")
  const reward = await deployments.get("reward")

  await deploy("Stake", {
    from: deployer,
    args: [30, 1, 5, BPT.address, reward.address],
    log: true,
  })
}
module.exports.tags = ["stake"]
module.exports.dependencies = ["reward", "BPT"]
