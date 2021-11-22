import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployMarebitsLocker: DeployFunction = async function(hardhatRuntimeEnvironment: HardhatRuntimeEnvironment) {
	const { deployments: { deploy }, getNamedAccounts } = hardhatRuntimeEnvironment;
	const { deployer } = await getNamedAccounts();
	await deploy("MarebitsLocker", { args: ["Mare Bits Locked Token", "\uD83D\uDC0E\u200D\u2640\uFE0F\uD83D\uDD12\uD83E\uDE99", "ipfs://ipfs/"], from: deployer, log: true });
};

export default deployMarebitsLocker;
deployMarebitsLocker.tags = ["MarebitsLocker"];