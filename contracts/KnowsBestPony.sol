// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

/**
 * @title The abstract Knows Best Pony contract
 * @author Twifag
 */
abstract contract KnowsBestPony {
	/** @return string the absolute best pony (hint: it's Twilight Sparkle) */
	function bestPony() public pure returns (string memory) { return "Twilight Sparkle is the cutest, smartest, all around best pony!"; }
}