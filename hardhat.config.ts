/**
 * @type import('hardhat/config').HardhatUserConfig
 */
import "@nomiclabs/hardhat-ethers";
import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy";
import * as Secrets from "./secrets.json";

const config: HardhatUserConfig = {
	namedAccounts: {
		deployer: {
			default: 0
		}
	}, 
	networks: {
		// ganache: {}, 
		localhost: {
			deploy: ["deploy", "deploy-test-tokens"]
		}, 
		mainnet: {
			chainId: 1, 
			gasMultiplier: 4, 
			timeout: 1000000, 
			url: `https://mainnet.infura.io/v3/${Secrets.INFURA_API_KEY}`
		}, 
		ropsten: {
			accounts: { mnemonic: Secrets.WALLET_MNEMONIC }, 
			chainId: 3, 
			gasMultiplier: 4, 
			timeout: 1000000, 
			url: Secrets.ALCHEMY_API_KEY
		}
	}, 
	solidity: {
		settings: {
			optimizer: {
				details: {
					constantOptimizer: true, 
					cse: true, 
					deduplicate: true, 
					jumpdestRemover: true, 
					peephole: true, 
					yul: false
				}, 
				runs: 200
			}
		}, 
		version: "0.8.10"
	}
};

export default config;