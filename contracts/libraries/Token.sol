// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

library Token {
	/** @dev Enum for token types; 0 is UNDEFINED, 1 is ERC1155, 2 is ERC20, and 3 is ERC721 */
	enum Type { UNDEFINED, ERC1155, ERC20, ERC721 }

	/**
	 * @param self representing a {Token.Type}
	 * @return bool true if `self` represents a valid token; otherwise, false
	 */
	function isValid(Type self) internal pure returns (bool) { return self == Type.ERC1155 || self == Type.ERC20 || self == Type.ERC721; }

	/**
	 * @param self representing a {Token.Type}
	 * @return bytes9 name of the token type `self`
	 */
	function nameOf(Type self) internal pure returns (bytes9) {
		bytes9[4] memory names = [bytes9("UNDEFINED"), "ERC1155", "ERC20", "ERC721"];

		if (uint8(self) > names.length - 1) {
			self = Type.UNDEFINED;
		}
		return names[uint8(self)];
	}
}