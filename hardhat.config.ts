/**
 * @type import('hardhat/config').HardhatUserConfig
 */
import "@nomiclabs/hardhat-ethers";
import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy";
import * as Secrets from "./secrets.json";

const config: HardhatUserConfig = {
	etherscan: { apiKey: Secrets.POLYGONSCAN_API_KEY }, 
	namedAccounts: {
		deployer: 0
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
			// deploy: ["deploy", "deploy-test-tokens"], 
			gas: 2100000, 
			gasMultiplier: 4, 
			gasPrice: 8000000000, 
			timeout: 1000000, 
			url: Secrets.ALCHEMY_API_KEY_ROPSTEN
		}, 
		polygon: {
			accounts: { mnemonic: Secrets.WALLET_MNEMONIC }, 
			chainId: 137, 
			gas: 50000000, 
			gasMultiplier: 6, 
			gasPrice: 8000000000, 
			timeout: 1000000, 
			url: Secrets.ALCHEMY_API_KEY_POLYGON
		}, 
		ganache: {
			accounts: { mnemonic: Secrets.WALLET_MNEMONIC }, 
			chainId: 1337, 
			deploy: ["deploy", "deploy-test-tokens"], 
			gas: 50000000, 
			gasMultiplier: 6, 
			gasPrice: 8000000000, 
			timeout: 1000000, 
			url: "http://127.0.0.1:7545"
		}, 
		mumbai: {
			accounts: { mnemonic: Secrets.WALLET_MNEMONIC }, 
			chainId: 80001, 
			gas: 50000000, 
			gasMultiplier: 6, 
			gasPrice: 8000000000, 
			timeout: 1000000, 
			url: Secrets.ALCHEMY_API_KEY_MUMBAI
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