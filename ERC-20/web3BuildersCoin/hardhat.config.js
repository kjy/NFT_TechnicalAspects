//require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ethers");
//require("@nomiclabs/hardhat-ethers");

// /** @type import('hardhat/config').HardhatUserConfig */

const privateKey="";

module.exports = {
  solidity: "0.8.19",
  defaultNetwork: "goerli",
  networks: {
    hardhat: {
    },
    goerli: {
      url: "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: [privateKey]
    }
  },
};


// google search hardhat config     https://hardhat.org/hardhat-runner/docs/config
// google rpc info goerli rpc node    https://rpc.info/
// npm install --save-dev@nomiclabs/hardhat-ethers
// npm install --save-dev @nomicfoundation/hardhat-ethers ethers

