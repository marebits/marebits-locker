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
import "@openzeppelin/contracts/utils/Strings.sol";

contract MarebitsLockerAccount is ERC165, TokenTypeable, RecoverableEther, RecoverableTokens, KnowsBestPony, IMarebitsLockerAccount {
	using Strings for uint256;

	mapping(uint256 => Account) private _accounts;

	function __createAccount(uint256 accountId, uint256 amount, address tokenContract, uint256 tokenId, TokenType tokenType, uint256 unlockTime) public onlyOwner {
		require(amount > 0, "`amount` must be greater than 0");
		require(tokenType != TokenType.ERC721 || amount == 1, "`amount` must be 1 for ERC721 tokens");
		require(tokenType == TokenType.ERC20 || tokenId > 0, "`tokenId` must be specified for ERC721 or ERC1155 tokens");
		require(unlockTime > block.timestamp, "`unlockTime` must be in the future");
		Account storage account = _accounts[accountId];
		(account.amount, account.tokenContract, account.tokenId, account.tokenType, account.unlockTime) = (amount, tokenContract, tokenId, tokenType, unlockTime);
		string memory tokenIdProperty = "";

		if (account.tokenId > 0) {
			tokenIdProperty = string(abi.encodePacked('"tokenId":"', account.tokenId.toString(), '",'));
		}
		account.metadata = string(abi.encodePacked('{"description":"This token entitles the holder to withdraw their locked token(s) after their lock period expires from the Mare Bits Locker.","external_url":"https://mare.biz/","image":"https://mare.biz/marebits/icon-960.png","name":"\\uD83D\\uDC0E\\u200D\\u2640\\uFE0F\\uD83D\\uDD12\\uD83E\\uDE99","properties": {"amount":"', account.amount.toString(), '","tokenContract":"', uint256(uint160(account.tokenContract)).toString(), '",', tokenIdProperty, '"unlockTime":"', account.unlockTime.toString(), '"}}'));
		account.tokenUri = string(verifyIPFS.generateHash(account.metadata));
	}

	function __setAmount(uint256 accountId, uint256 amount) external onlyOwner { _accounts[accountId].amount = amount; }

	function __setUnlockTime(uint256 accountId, uint256 unlockTime) external onlyOwner { _accounts[accountId].unlockTime = unlockTime; }

	function getAccount(uint256 accountId) external view returns (Account memory) { return _accounts[accountId]; }

	function getAmount(uint256 accountId) external view returns (uint256) { return _accounts[accountId].amount; }

	function getMetadata(uint256 accountId) external view returns (string memory) { return _accounts[accountId].metadata; }

	function getTokenContract(uint256 accountId) external view returns (address) { return _accounts[accountId].tokenContract; }

	function getTokenType(uint256 accountId) external view returns (TokenType) { return _accounts[accountId].tokenType; }

	function getTokenId(uint256 accountId) external view returns (uint256) { return _accounts[accountId].tokenId; }

	function getTokenUri(uint256 accountId) external view returns (string memory) { return _accounts[accountId].tokenUri; }

	function getUnlockTime(uint256 accountId) external view returns (uint256) { return _accounts[accountId].unlockTime; }

	function isUnlocked(uint256 accountId) external view returns (bool) { return _accounts[accountId].unlockTime <= block.timestamp; }

	/**
	* @dev Implementation of the {IERC165} interface.
	* @param interfaceId to check
	* @return true if the interfaceId is supported and false if it is not
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