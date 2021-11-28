// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./interfaces/IMarebitsLockerAccount.sol";
import "./libraries/Account.sol";
import "./libraries/Token.sol";
import "./KnowsBestPony.sol";
import "./Ownable.sol";
import "./Recoverable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title The implementation for the Mare Bits Locker Account
 * @author Twifag
 */
contract MarebitsLockerAccount is Recoverable, KnowsBestPony, IMarebitsLockerAccount {
	using Account for mapping(uint256 => Account.Info);
	using Account for Account.Info;

	/** @dev the maximum value for time (uint64) */
	uint64 private constant MAXIMUM_TIME = (2 << 63) - 1;

	/** @dev Stores all the accounts; `accountId` => {IMarebitsLockerAccount.Account} */
	mapping(uint256 => Account.Info) private _accounts;

	/**
	 * @dev The account must exist
	 * @param accountId (also `tokenId`) representing the locked account
	 */
	modifier accountExists(uint256 accountId) {
		if (!_accounts[accountId].isDefined()) {
			revert NonexistentAccount(accountId);
		}
		_;
	}

	/// @inheritdoc IMarebitsLockerAccount
	function __createAccount(uint256 accountId, uint256 amount, address tokenContract, uint256 tokenId, Token.Type tokenType, uint64 unlockTime) public onlyOwner {
		if (amount == 0) {
			revert ZeroAmountGiven();
		} else if (tokenType == Token.Type.ERC721 && amount > 1) {
			revert InvalidAmount("`amount` must be 1 for ERC721");
		} else if (uint256(unlockTime) <= block.timestamp) {
			revert TimeOutOfBounds(unlockTime, uint64(block.timestamp), MAXIMUM_TIME);
		}
		_accounts.create(accountId, amount, tokenContract, tokenId, tokenType, unlockTime);
	}

	/// @inheritdoc IMarebitsLockerAccount
	function __burn(uint256 accountId) external onlyOwner accountExists(accountId) { _accounts[accountId].burn(); }

	/// @inheritdoc IMarebitsLockerAccount
	function __redeem(uint256 accountId) external onlyOwner accountExists(accountId) { _accounts[accountId].redeem(); }

	/// @inheritdoc IMarebitsLockerAccount
	function __setAmount(uint256 accountId, uint256 amount) external onlyOwner accountExists(accountId) { _accounts[accountId].setAmount(amount); }

	/// @inheritdoc IMarebitsLockerAccount
	function __setUnlockTime(uint256 accountId, uint64 unlockTime) external onlyOwner accountExists(accountId) { _accounts[accountId].setUnlockTime(unlockTime); }

	/// @inheritdoc IMarebitsLockerAccount
	function getAccount(uint256 accountId) external view accountExists(accountId) returns (Account.Info memory) { return _accounts[accountId]; }

	/// @inheritdoc IMarebitsLockerAccount
	function getAmount(uint256 accountId) external view accountExists(accountId) returns (uint256) { return _accounts[accountId].amount; }

	/// @inheritdoc IMarebitsLockerAccount
	function getTokenContract(uint256 accountId) external view accountExists(accountId) returns (address) { return _accounts[accountId].tokenContract; }

	/// @inheritdoc IMarebitsLockerAccount
	function getTokenType(uint256 accountId) external view accountExists(accountId) returns (Token.Type) { return _accounts[accountId].tokenType; }

	/// @inheritdoc IMarebitsLockerAccount
	function getTokenId(uint256 accountId) external view accountExists(accountId) returns (uint256) { return _accounts[accountId].tokenId; }

	/// @inheritdoc IMarebitsLockerAccount
	function getUnlockTime(uint256 accountId) external view accountExists(accountId) returns (uint64) { return _accounts[accountId].unlockTime; }

	/// @inheritdoc IMarebitsLockerAccount
	function hasAccount(uint256 accountId) external view returns (bool) { return _accounts[accountId].isDefined(); }

	/// @inheritdoc IMarebitsLockerAccount
	function isUnlocked(uint256 accountId) external view accountExists(accountId) returns (bool) { return _accounts[accountId].isUnlocked(); }

	/**
	* @dev Implementation of the {IERC165} interface.
	* @inheritdoc ERC165
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, Recoverable) returns (bool) {
		return interfaceId == type(IMarebitsLockerAccount).interfaceId || 
			interfaceId == type(KnowsBestPony).interfaceId || 
			interfaceId == type(Recoverable).interfaceId || 
			super.supportsInterface(interfaceId);
	}
}