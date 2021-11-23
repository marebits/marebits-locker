// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./interfaces/IMarebitsLockerAccount.sol";
import "./KnowsBestPony.sol";
import "./RecoverableEther.sol";
import "./RecoverableTokens.sol";
import "./TokenTypeable.sol";
// import "./verifyIPFS-master/contracts/verifyIPFS.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title The implementation for the Mare Bits Locker Account
 * @author Twifag
 */
contract MarebitsLockerAccount is ERC165, TokenTypeable, RecoverableEther, RecoverableTokens, KnowsBestPony, IMarebitsLockerAccount {
	// using Strings for uint256;

	/** @dev Stores all the accounts; `accountId` => {IMarebitsLockerAccount.Account} */
	mapping(uint256 => Account) private _accounts;

	/**
	 * @dev The account must exist
	 * @param accountId (also `tokenId`) representing the locked account
	 */
	modifier accountExists(uint256 accountId) {
		require(_accounts[accountId].tokenType != TokenType.UNDEFINED, "`accountId` does not exist");
		_;
	}

	/**
	 * @notice Creates a new {IMarebitsLockerAccount.Account}
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param accountId representing the new account
	 * @param amount of tokens to lock in locker
	 * @param tokenContract for the token to be locked
	 * @param tokenId of the token to be locked; should always be 0 for locked ERC20 tokens
	 * @param tokenType of token to be locked; see {ITokenTypeable.TokenType}
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 */
	function __createAccount(uint256 accountId, uint256 amount, address tokenContract, uint256 tokenId, TokenType tokenType, uint64 unlockTime) public onlyOwner {
		require(amount > 0, "`amount` must be greater than 0");
		require(tokenType != TokenType.ERC721 || amount == 1, "`amount` must be 1 for ERC721 tokens");
		require(uint256(unlockTime) > block.timestamp, "`unlockTime` must be in the future");
		Account storage account = _accounts[accountId];
		(account.amount, account.tokenContract, account.tokenId, account.tokenType, account.unlockTime) = (amount, tokenContract, tokenId, tokenType, unlockTime);
		// _generateMetadata(account);
	}

	/**
	 * @notice Updates the amount of tokens locked in this account to `amount`; should only be called during a burn/redemption
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param accountId representing the account
	 * @param amount new amount of tokens to be locked
	 */
	function __setAmount(uint256 accountId, uint256 amount) external onlyOwner accountExists(accountId) {
		_accounts[accountId].amount = amount;
		// _generateMetadata(_accounts[accountId]);
	}

	/**
	 * @notice Updates the unlock time of tokens locked in this account to `unlockTime`; called by {IMarebitsLocker.extendLock}
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param accountId representing the account
	 * @param unlockTime in seconds after UNIX epoch
	 */
	function __setUnlockTime(uint256 accountId, uint64 unlockTime) external onlyOwner accountExists(accountId) {
		_accounts[accountId].unlockTime = unlockTime;
		// _generateMetadata(_accounts[accountId]);
	}

	// function _generateMetadata(Account storage account) private {
	// 	account.metadata = string(abi.encodePacked('{"description":"This token entitles the holder to withdraw their locked token(s) after their lock period expires from the Mare Bits Locker.","external_url":"https://mare.biz/","image":"https://mare.biz/marebits/icon-960.png","name":"\\uD83D\\uDC0E\\u200D\\u2640\\uFE0F\\uD83D\\uDD12\\uD83E\\uDE99","properties": {"amount":"', account.amount.toString(), '","tokenContract":"', uint256(uint160(account.tokenContract)).toString(), '","tokenType":"', (account.tokenType == TokenType.ERC1155) ? "ERC1155" : (account.tokenType == TokenType.ERC20) ? "ERC20" : (account.tokenType == TokenType.ERC721) ? "ERC721" : "UNKNOWN", '",', (account.tokenId > 0) ? string(abi.encodePacked('"tokenId":"', account.tokenId.toString(), '",')) : "", '"unlockTime":"', account.unlockTime.toString(), '"}}'));
	// 	account.tokenUri = string(verifyIPFS.generateHash(account.metadata));
	// }

	/// @inheritdoc IMarebitsLockerAccount
	function getAccount(uint256 accountId) external view accountExists(accountId) returns (Account memory) { return _accounts[accountId]; }

	/// @inheritdoc IMarebitsLockerAccount
	function getAmount(uint256 accountId) external view accountExists(accountId) returns (uint256) { return _accounts[accountId].amount; }

	// function getMetadata(uint256 accountId) external view accountExists(accountId) returns (string memory) { return _accounts[accountId].metadata; }

	/// @inheritdoc IMarebitsLockerAccount
	function getTokenContract(uint256 accountId) external view accountExists(accountId) returns (address) { return _accounts[accountId].tokenContract; }

	/// @inheritdoc IMarebitsLockerAccount
	function getTokenType(uint256 accountId) external view accountExists(accountId) returns (TokenType) { return _accounts[accountId].tokenType; }

	/// @inheritdoc IMarebitsLockerAccount
	function getTokenId(uint256 accountId) external view accountExists(accountId) returns (uint256) { return _accounts[accountId].tokenId; }

	// function getTokenUri(uint256 accountId) external view accountExists(accountId) returns (string memory) { return _accounts[accountId].tokenUri; }

	/// @inheritdoc IMarebitsLockerAccount
	function getUnlockTime(uint256 accountId) external view accountExists(accountId) returns (uint64) { return _accounts[accountId].unlockTime; }

	/// @inheritdoc IMarebitsLockerAccount
	function hasAccount(uint256 accountId) external view returns (bool) { return _accounts[accountId].tokenType != TokenType.UNDEFINED; }

	/// @inheritdoc IMarebitsLockerAccount
	function isUnlocked(uint256 accountId) external view accountExists(accountId) returns (bool) { return uint256(_accounts[accountId].unlockTime) <= block.timestamp; }

	/**
	* @dev Implementation of the {IERC165} interface.
	* @inheritdoc ERC165
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
		return interfaceId == type(KnowsBestPony).interfaceId || 
			interfaceId == type(Ownable).interfaceId || 
			interfaceId == type(RecoverableEther).interfaceId ||
			interfaceId == type(RecoverableTokens).interfaceId || 
			interfaceId == type(IMarebitsLockerAccount).interfaceId || 
			super.supportsInterface(interfaceId);
	}
}