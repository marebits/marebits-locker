import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

// to deploy using ledger https://github.com/nomiclabs/hardhat/issues/1159
// import * as ethProvider from "eth-provider";
// const ethProvider = require("eth-provider");
// const frame = ethProvider("frame");

const deployMarebitsLocker: DeployFunction = async function({ deployments, getChainId, getNamedAccounts, getUnnamedAccounts }: HardhatRuntimeEnvironment) {
	// to deploy using ledger https://github.com/nomiclabs/hardhat/issues/1159
	// const MarebitsLocker = await ethers.getContractFactory("MarebitsLocker");
	// const tx = await MarebitsLocker.getDeployTransaction();
	// tx.from = (await frame.request({ method: "eth_requestAccounts" }))[0];
	// await frame.request({ method: "eth_sendTransaction", params: [tx] });
	const chainId: string = await getChainId();
	const deployer: string = (await getNamedAccounts()).deployer;
	const baseURI: string = `https://locker.mare.biz/token/${chainId}/`;
	const name: string = "Mare Bits Locker Token";
	const symbol: string = "\uD83D\uDC0E\u200D\u2640\uFE0F\uD83D\uDD12\uD83E\uDE99";
	const mareBitsToken: string = ((): string => {
		switch (chainId) {
			case "1": // mainnet
				return "0xc5a1973e1f736e2ad991573f3649f4f4a44c3028";
			case "3": // ropsten
				return "0x35c94a5a563d7dc00b7edaa455e0a931691deb27";
			case "137": // polygon
				return "0xb362A97aD06C907c4b575D3503fB9DC474498480";
			default:
				return "0x0000000000000000000000000000000000000000";
		}
	})();
	const args: Array<string> = [name, symbol, baseURI, mareBitsToken];
	console.log(args);
	await deployments.deploy("MarebitsLocker", { args, from: deployer, log: true });
};

export default deployMarebitsLocker;
deployMarebitsLocker.tags = ["MarebitsLocker"];