// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

/**
 * @title The interface for Token Typeable; allows a contract to use the `TokenType` enum
 * @author Twifag
 */
interface ITokenTypeable {
	/** @dev Enum for token types; 0 is UNDEFINED, 1 is ERC1155, 2 is ERC20, and 3 is ERC721 */
	enum TokenType { UNDEFINED, ERC1155, ERC20, ERC721 }
}