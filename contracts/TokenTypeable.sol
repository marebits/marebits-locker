// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

abstract contract TokenTypeable {
	enum TokenType { UNDEFINED, ERC1155, ERC20, ERC721 }

	modifier isValidTokenType(TokenType tokenType) {
		require(tokenType == TokenType.ERC1155 || tokenType == TokenType.ERC20 || tokenType == TokenType.ERC721, "`tokenType` must represent a supported token: 1 for ERC1155, 2 for ERC20, or 3 for ERC721");
		_;
	}
}