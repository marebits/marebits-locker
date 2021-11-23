import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployTestTokens: DeployFunction = async function({ deployments, getChainId, getNamedAccounts, getUnnamedAccounts }: HardhatRuntimeEnvironment) {
	const deployer: string = (await getNamedAccounts()).deployer;
	await deployments.deploy("TestERC20", { args: [], from: deployer, log: true });
	await deployments.deploy("TestERC721", { args: [], from: deployer, log: true });
	await deployments.deploy("TestERC1155", { args: [], from: deployer, log: true });
};

export default deployTestTokens;
deployTestTokens.tags = ["TestERC20", "TestERC721", "TestERC1155"];