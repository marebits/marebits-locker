// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

abstract contract KnowsBestPony {
	/**
	 * @return the best pony.
	 * 
	 */
	function bestPony() public pure returns (string memory) { return "Twilight Sparkle is the cutest, smartest, all around best pony!"; }
}