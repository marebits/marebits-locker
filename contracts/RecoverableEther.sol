// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title The abstract Recoverable Ether contract
 * @author Twifag
 */
abstract contract RecoverableEther is Ownable {
	/**
	 * @notice Recovers ether accidentally sent to this contract
	 * @dev Only callable by the {Ownable.owner} of this contract
	 */
	function __recoverEther() public virtual payable onlyOwner { payable(owner()).transfer(address(this).balance); }
}