// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./interfaces/IOwnable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title Ownable abstract contract
 * @dev Closely (but not quite, see {TransferrableOwnership}) implements [ERC-173](https://eips.ethereum.org/EIPS/eip-173)
 */
abstract contract Ownable is Context, ERC165, IOwnable {
	address private _owner;

	/// @dev Initializes the contract setting the deployer as the initial owner.
	constructor() { _transferOwnership(_msgSender()); }

	/// @dev Throws if called by any account other than the owner.
	modifier onlyOwner() {
		if (owner() != _msgSender()) {
			revert CallerIsNotOwner(_msgSender(), owner());
		}
		_;
	}

	/// @dev Transfers ownership of the contract to a new account (`newOwner`)
	function _transferOwnership(address newOwner) internal virtual {
		address oldOwner = owner();
		_owner = newOwner;
		emit OwnershipTransferred(oldOwner, owner());
	}

	/// @inheritdoc IOwnable
	function owner() public view returns (address) { return _owner; }

	/**
	* @dev Implementation of the {IERC165} interface.
	* @inheritdoc ERC165
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
		return interfaceId == type(IOwnable).interfaceId || 
			super.supportsInterface(interfaceId);
	}
}