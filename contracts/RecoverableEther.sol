// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./interfaces/IRecoverableEther.sol";
import "./Ownable.sol";

/**
 * @title The abstract Recoverable Ether contract
 * @author Twifag
 */
abstract contract RecoverableEther is Ownable, IRecoverableEther {
	// @inheritdoc IRecoverableEther
	function __recoverEther() public virtual override payable onlyOwner {
		(bool success, ) = payable(owner()).call{value: address(this).balance}("");

		if (!success) {
			revert FailedSend();
		}
	}

	/**
	* @dev Implementation of the {IERC165} interface.
	* @inheritdoc ERC165
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, Ownable) returns (bool) {
		return interfaceId == type(IRecoverableEther).interfaceId || 
			super.supportsInterface(interfaceId);
	}
}