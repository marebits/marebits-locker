// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./interfaces/IMarebitsLockerAccount.sol";
import "./KnowsBestPony.sol";
import "./RecoverableEther.sol";
import "./RecoverableTokens.sol";
import "./TokenTypeable.sol";
import "./verifyIPFS-master/contracts/verifyIPFS.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title The implementation for the Mare Bits Locker Account
 * @author Twifag
 */
contract MarebitsLockerAccount is ERC165, TokenTypeable, RecoverableEther, RecoverableTokens, KnowsBestPony, IMarebitsLockerAccount {
	using SafeCast for uint256;
	using Strings for uint256;

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

	/// @inheritdoc IMarebitsLockerAccount
	function __createAccount(uint256 accountId, uint256 amount, address tokenContract, uint256 tokenId, TokenType tokenType, uint64 unlockTime) public onlyOwner {
		require(amount > 0, "`amount` must be greater than 0");
		require(tokenType != TokenType.ERC721 || amount == 1, "`amount` must be 1 for ERC721 tokens");
		require(uint256(unlockTime) > block.timestamp, "`unlockTime` must be in the future");
		_accounts[accountId] = Account(amount, tokenContract, tokenId, tokenType, false, unlockTime);
	}

	/// @inheritdoc IMarebitsLockerAccount
	function __redeem(uint256 accountId) external onlyOwner accountExists(accountId) {
		_accounts[accountId].amount = 0;
		_accounts[accountId].isRedeemed = true;
		_accounts[accountId].unlockTime = block.timestamp.toUint64();
	}

	/// @inheritdoc IMarebitsLockerAccount
	function __setAmount(uint256 accountId, uint256 amount) external onlyOwner accountExists(accountId) { _accounts[accountId].amount = amount; }

	/// @inheritdoc IMarebitsLockerAccount
	function __setUnlockTime(uint256 accountId, uint64 unlockTime) external onlyOwner accountExists(accountId) { _accounts[accountId].unlockTime = unlockTime; }

	/// @inheritdoc IMarebitsLockerAccount
	function getAccount(uint256 accountId) external view accountExists(accountId) returns (Account memory) { return _accounts[accountId]; }

	/// @inheritdoc IMarebitsLockerAccount
	function getAmount(uint256 accountId) external view accountExists(accountId) returns (uint256) { return _accounts[accountId].amount; }

	/// @inheritdoc IMarebitsLockerAccount
	function getMetadata(uint256 accountId) public view accountExists(accountId) returns (string memory) {
		return string(abi.encodePacked(
			'{'
				'"description":"This token entitles the holder to withdraw their locked token(s) after their lock period expires from the Mare Bits Locker.",'
				'"external_url":"https://mare.biz/",'
				'"image":"https://mare.biz/marebits/icon-960.png",'
				'"name":"\\uD83D\\uDC0E\\u200D\\u2640\\uFE0F\\uD83D\\uDD12\\uD83E\\uDE99",'
				'"properties":{'
					'"amount":"', _accounts[accountId].amount.toString(), '",'
					'"isRedeemed":', _accounts[accountId].isRedeemed ? "true" : "false", ','
					'"tokenContract":"', uint256(uint160(_accounts[accountId].tokenContract)).toString(), '",'
					'"tokenType":"', getTokenTypeName(_accounts[accountId].tokenType), '",'
					'"tokenId":"', _accounts[accountId].tokenId, ','
					'"unlockTime":"', uint256(_accounts[accountId].unlockTime).toString(), '"'
				'}'
			'}'
		));
	}

	/// @inheritdoc IMarebitsLockerAccount
	function getTokenContract(uint256 accountId) external view accountExists(accountId) returns (address) { return _accounts[accountId].tokenContract; }

	/// @inheritdoc IMarebitsLockerAccount
	function getTokenType(uint256 accountId) external view accountExists(accountId) returns (TokenType) { return _accounts[accountId].tokenType; }

	/// @inheritdoc IMarebitsLockerAccount
	function getTokenId(uint256 accountId) external view accountExists(accountId) returns (uint256) { return _accounts[accountId].tokenId; }

	/// @inheritdoc IMarebitsLockerAccount
	function getTokenUri(uint256 accountId) external view accountExists(accountId) returns (string memory) { return string(verifyIPFS.generateHash(getMetadata(accountId))); }

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
		return interfaceId == type(IMarebitsLockerAccount).interfaceId || 
			interfaceId == type(KnowsBestPony).interfaceId || 
			interfaceId == type(Ownable).interfaceId || 
			interfaceId == type(RecoverableEther).interfaceId ||
			interfaceId == type(RecoverableTokens).interfaceId || 
			interfaceId == type(TokenTypeable).interfaceId || 
			super.supportsInterface(interfaceId);
	}
}