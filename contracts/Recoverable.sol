// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./RecoverableEther.sol";
import "./RecoverableTokens.sol";

abstract contract Recoverable is RecoverableEther, RecoverableTokens {
	/**
	* @dev Implementation of the {IERC165} interface.
	* @inheritdoc ERC165
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(RecoverableEther, RecoverableTokens) returns (bool) {
		return RecoverableEther.supportsInterface(interfaceId) || 
			RecoverableTokens.supportsInterface(interfaceId);
	}
}