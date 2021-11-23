// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./TokenTypeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title The abstract Recoverable Tokens contract
 * @author Twifag
 */
abstract contract RecoverableTokens is Ownable, TokenTypeable {
	using SafeERC20 for IERC20;

	/**
	 * @dev Recovers ERC1155 tokens accidentally sent to this contract
	 * @param token to recover
	 * @param tokenId to recover
	 */
	function __recoverERC1155(IERC1155 token, uint256 tokenId) internal { token.safeTransferFrom(address(this), payable(owner()), tokenId, token.balanceOf(address(this), tokenId), ""); }

	/**
	 * @dev Recovers ERC20 tokens accidentally sent to this contract
	 * @param token to recover
	 */
	function __recoverERC20(IERC20 token) internal { token.safeTransfer(payable(owner()), token.balanceOf(address(this))); }

	/**
	 * @dev Recovers ERC721 tokens accidentally sent to this contract
	 * @param token to recover
	 * @param tokenId to recover
	 */
	function __recoverERC721(IERC721 token, uint256 tokenId) internal { token.safeTransferFrom(address(this), payable(owner()), tokenId); }

	/**
	 * @notice Recovers ERC20, ERC721, or ERC1155 tokens accidentally sent to this contract
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param tokenType of token to recover; see {ITokenTypeable.TokenType}
	 * @param tokenContract address of the token to recover
	 * @param tokenId of the token to recover; should always be 0 for ERC20 tokens
	 */
	function __recoverTokens(TokenType tokenType, address tokenContract, uint256 tokenId) public virtual onlyOwner {
		if (tokenType == TokenType.ERC1155) {
			__recoverERC1155(IERC1155(tokenContract), tokenId);
		} else if (tokenType == TokenType.ERC20) {
			__recoverERC20(IERC20(tokenContract));
		} else if (tokenType == TokenType.ERC721) {
			__recoverERC721(IERC721(tokenContract), tokenId);
		}
	}
}