// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title The abstract Recoverable Ether contract
 * @author Twifag
 */
interface IRecoverableEther is IERC165 {
	/** @notice Thrown when the send fails */
	error FailedSend();

	/**
	 * @notice Recovers ether accidentally sent to this contract
	 * @dev Only callable by the {Ownable.owner} of this contract
	 */
	function __recoverEther() external payable;
}