module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()
  await deploy("reward", {
    contract: "ProjectERC20",
    from: deployer,
    args: ["RewardToken", "RT"],
    log: true,
  })
}
module.exports.tags = ["reward"]
