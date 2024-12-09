module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()
  await deploy("BPT", {
    contract: "ProjectERC20",
    from: deployer,
    args: ["BPT", "BPT"],
    log: true,
  })
}
module.exports.tags = ["BPT"]
