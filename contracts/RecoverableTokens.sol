// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./TokenTypeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract RecoverableTokens is Ownable, TokenTypeable {
	using SafeERC20 for IERC20;

	/**
	 * @dev Withdraw the ERC1155 token of the given type to this contract owner's wallet, does not effect the vault. No tokens should be sent directly to this contract, this fixes instances where they mistakenly are.
	 * @param token to withdraw
	 * @param tokenId to withdraw
	 */
	function __recoverERC1155(IERC1155 token, uint256 tokenId) internal { token.safeTransferFrom(address(this), payable(owner()), tokenId, token.balanceOf(address(this), tokenId), ""); }

	/**
	 * @dev Withdraw all ERC20 tokens of the given type to this contract owner's wallet, does not effect the vault. No tokens should be sent directly to this contract, this fixes instances where they mistakenly are.
	 * @param token to withdraw
	 */
	function __recoverERC20(IERC20 token) internal { token.safeTransfer(payable(owner()), token.balanceOf(address(this))); }

	/**
	 * @dev Withdraw the ERC721 token of the given type to this contract owner's wallet, does not effect the vault. No tokens should be sent directly to this contract, this fixes instances where they mistakenly are.
	 * @param token to withdraw
	 * @param tokenId to withdraw
	 */
	function __recoverERC721(IERC721 token, uint256 tokenId) internal { token.safeTransferFrom(address(this), payable(owner()), tokenId); }

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