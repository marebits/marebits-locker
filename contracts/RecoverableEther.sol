// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract RecoverableEther is Ownable {
	/**
	 * @dev Redirect sent ether, no ether should ever be sent to this contract
	 */
	modifier redirectEther() {
		if (msg.value > 0) {
			payable(owner()).transfer(msg.value);
		}
		_;
	}
	
	function __recoverEther() public virtual payable onlyOwner { payable(owner()).transfer(address(this).balance); }
}