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
	await deployments.deploy("MarebitsLocker", {
		args: ["Mare Bits Locker Token", "\uD83D\uDC0E\u200D\u2640\uFE0F\uD83D\uDD12\uD83E\uDE99", "https://locker.mare.biz/account/"], 
		from: (await getNamedAccounts()).deployer, 
		log: true
	});
};

export default deployMarebitsLocker;
deployMarebitsLocker.tags = ["MarebitsLocker"];