// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./ITokenTypeable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IMarebitsLockerAccount is IERC165, ITokenTypeable {
	struct Account {
		uint256 amount;
		string metadata;
		address tokenContract;
		uint256 tokenId;
		TokenType tokenType;
		string tokenUri;
		uint256 unlockTime;
	}

	function getAccount(uint256 accountId) external view returns (Account memory);
	function getAmount(uint256 accountId) external view returns (uint256);
	function getMetadata(uint256 accountId) external view returns (string memory);
	function getTokenContract(uint256 accountId) external view returns (address);
	function getTokenType(uint256 accountId) external view returns (TokenType);
	function getTokenId(uint256 accountId) external view returns (uint256);
	function getTokenUri(uint256 accountId) external view returns (string memory);
	function getUnlockTime(uint256 accountId) external view returns (uint256);
	function hasAccount(uint256 accountId) external view returns (bool);
	function isUnlocked(uint256 accountId) external view returns (bool);
}