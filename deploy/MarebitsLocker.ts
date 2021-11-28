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
	const deployer: string = (await getNamedAccounts()).deployer;
	const marebitsLockerTokenMetadataSVGBuilder = await deployments.deploy("MarebitsLockerTokenMetadataSVGBuilder", { from: deployer, log: true });
	const marebitsLockerTokenMetadataBuilder = await deployments.deploy("MarebitsLockerTokenMetadataBuilder", {
		from: deployer, 
		libraries: { MarebitsLockerTokenMetadataSVGBuilder: marebitsLockerTokenMetadataSVGBuilder.address }, 
		log: true
	});

	await deployments.deploy("MarebitsLocker", {
		args: ["Mare Bits Locker Token", "\uD83D\uDC0E\u200D\u2640\uFE0F\uD83D\uDD12\uD83E\uDE99", "ipfs://ipfs/"], 
		from: deployer, 
		libraries: { MarebitsLockerTokenMetadataBuilder: marebitsLockerTokenMetadataBuilder.address }, 
		log: true
	});
};

export default deployMarebitsLocker;
deployMarebitsLocker.tags = ["MarebitsLocker"];