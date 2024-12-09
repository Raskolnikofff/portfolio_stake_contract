require('hardhat-deploy');
require("@nomiclabs/hardhat-waffle");
accounts={mnemonic:process.env.MNEMONIC ||""}

module.exports = {
  networks: {
    hardhat: {
      accounts,
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts,
    }
  },
  namedAccounts: {
    deployer: 0,
  },
  solidity: {
    version: "0.8.7",
  },
}
