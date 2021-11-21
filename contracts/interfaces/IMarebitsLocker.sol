// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./IMarebitsLockerAccount.sol";
import "./ITokenTypeable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IMarebitsLocker is IERC165, ITokenTypeable {
	event TokensLocked(uint256 indexed accountId, address indexed owner, uint256 amount, address tokenContract, uint256 tokenId, TokenType tokenType, uint256 unlockTime);
	event TokensRedeemed(uint256 indexed accountId, address indexed owner, uint256 amount, address tokenContract, uint256 tokenId, TokenType tokenType);
	
	function extendLock(uint256 accountId, uint256 unlockTime) external;
	function getAccount(uint256 accountId) external view returns (IMarebitsLockerAccount.Account memory);
	function lockTokens(TokenType tokenType, address tokenContract, uint256 tokenId, uint256 amount, uint256 unlockTime) external returns (uint256);
	function redeemToken(uint256 accountId) external;
}