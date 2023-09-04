// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
    const Web3Builder = await hre.ethers.getContractFactory("Web3Builder");
    const web3Builder = await Web3Builder.deploy();

    await web3Builder.waitForDeployment();
    
    console.log("Crypto coin deployed to: ", web3Builder.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat run --network goerli scripts/script.js

// (base) karenjyang@Karens-MBP web3BuildersCoin % npx hardhat run --network goerli scripts/script.js
// Crypto coin deployed to:  0x6651a4278c35Ce606941c81a7dC0e823Fce79001
// https://goerli.etherscan.io/address/0x6651a4278c35Ce606941c81a7dC0e823Fce79001

 
// https://pancakeswap.finance/   ethereum connect wallet MetaMask Switch network then later switch to goerli
