// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./interfaces/ITokenTypeable.sol";

/**
 * @title The abstract Token Typeable contract implementation
 * @author Twifag
 */
abstract contract TokenTypeable is ITokenTypeable {
	/**
	 * @dev The token type `tokenType` must be a valid type
	 * @param tokenType to check; see {ITokenTypeable.TokenType}
	 */
	modifier isValidTokenType(TokenType tokenType) {
		require(tokenType == TokenType.ERC1155 || tokenType == TokenType.ERC20 || tokenType == TokenType.ERC721, "`tokenType` must represent a supported token: 1 for ERC1155, 2 for ERC20, or 3 for ERC721");
		_;
	}
}