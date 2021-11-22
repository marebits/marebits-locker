/**
 * @type import('hardhat/config').HardhatUserConfig
 */
import "@nomiclabs/hardhat-ethers";
import "hardhat-deploy";
import { HardhatUserConfig } from "hardhat/config";

const config: HardhatUserConfig = {
	namedAccounts: { deployer: 0 }, 
	solidity: "0.8.10"
};

export default config;