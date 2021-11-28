// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./interfaces/IOwnershipTransferrable.sol";
import "./Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

abstract contract OwnershipTransferrable is Ownable, IOwnershipTransferrable {
	/// @inheritdoc IOwnershipTransferrable
	function renounceOwnership() public virtual onlyOwner { _transferOwnership(address(0)); }

	/**
	* @dev Implementation of the {IERC165} interface.
	* @inheritdoc ERC165
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, Ownable) returns (bool) {
		return interfaceId == type(IOwnershipTransferrable).interfaceId || 
			super.supportsInterface(interfaceId);
	}

	/// @inheritdoc IOwnershipTransferrable
	function transferOwnership(address newOwner) public virtual onlyOwner {
		if (newOwner == address(0)) {
			revert OwnerCannotBeZero();
		}
		_transferOwnership(newOwner);
	}
}