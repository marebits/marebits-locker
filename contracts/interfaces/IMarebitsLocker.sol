// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./ITokenTypeable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IMarebitsLocker is IERC165, ITokenTypeable {
	event TokensLocked(uint256 indexed lockerTokenId, address indexed owner, uint256 amount, address tokenContract, uint256 tokenId, TokenType tokenType, uint256 unlockTime);
	event TokensRedeemed(uint256 indexed lockerTokenId, address indexed owner, uint256 amount, address tokenContract, uint256 tokenId, TokenType tokenType);
	
	function extendLock(uint256 tokenId, uint256 unlockTime) external;
	function getAccount(uint256 tokenId) external view returns (uint256, string memory, address, uint256, TokenType, string memory, uint256);
	function lockTokens(TokenType tokenType, address tokenContract, uint256 tokenId, uint256 amount, uint256 unlockTime) external;
	function redeemToken(uint256 tokenId) external;
}