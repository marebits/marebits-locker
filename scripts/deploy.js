async function main() {
	const MarebitsLocker = await ethers.getContractFactory("MarebitsLocker");
	const marebitsLocker = await MarebitsLocker.deploy("Mare Bits Locked Token", "\uD83D\uDC0E\u200D\u2640\uFE0F\uD83D\uDD12\uD83E\uDE99", "ipfs://ipfs/");
	await marebitsLocker.deployed();
	console.log("MarebitsLocker deployed to: ", marebitsLocker.address);
}

(async function() {
	await main();
	process.exit(0);
})().catch(function(err) {
	console.error(err);
	process.exit(1);
});