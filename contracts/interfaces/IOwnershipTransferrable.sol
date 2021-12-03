// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./IOwnable.sol";

/**
 * @title Ownable abstract contract
 * @dev Represents the [ERC-173](https://eips.ethereum.org/EIPS/eip-173) specification (and a little more)
 */
interface IOwnershipTransferrable is IOwnable {
	/**
	 * @notice Leaves the contract without owner.  It will not be possible to call `onlyOwner` functions anymore.
	 * @dev Can only be called by the current owner.
	 */
	// function renounceOwnership() external;

	/**
	 * @notice Transfers ownership of the contract to a new account (`newAccount`).
	 * @dev Can only be called by the current owner.
	 * @param newOwner address of the new owner
	 */
	function transferOwnership(address newOwner) external;
}