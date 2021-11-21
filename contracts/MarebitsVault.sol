// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./KnowsBestPony.sol";
import "./RecoverableEther.sol";
import "./TokenTypeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract MarebitsVault is ERC1155Holder, ERC721Holder, KnowsBestPony, RecoverableEther, TokenTypeable {
	using SafeERC20 for IERC20;

	function __transfer(TokenType tokenType, address tokenContract, address payable to, uint256 tokenId, uint256 amount) external onlyOwner {
		if (tokenType == TokenType.ERC1155) {
			_transferERC1155(IERC1155(tokenContract), to, tokenId, amount);
		} else if (tokenType == TokenType.ERC20) {
			_transferERC20(IERC20(tokenContract), to, amount);
		} else if (tokenType == TokenType.ERC721) {
			_transferERC721(IERC721(tokenContract), to, tokenId);
		}
	}

	/**
	 * @dev Transfer ERC1155 tokens to destination, used to move tokens from the vault to the owner on withdraw
	 * @param token to transfer
	 * @param to wallet address
	 * @param amount of ERC1155 tokens to transfer
	 */
	function _transferERC1155(IERC1155 token, address payable to, uint256 tokenId, uint256 amount) private { token.safeTransferFrom(address(this), to, tokenId, amount, ""); }

	/**
	 * @dev Transfer ERC20 tokens to destination, used to move tokens from the vault to the owner on withdraw
	 * @param token to transfer
	 * @param to wallet address
	 * @param amount of ERC20 tokens to transfer
	 */
	function _transferERC20(IERC20 token, address payable to, uint256 amount) private { token.safeTransfer(to, amount); }

	/**
	 * @dev Transfer ERC721 token to destination, used to move token from the vault to the owner on withdraw
	 * @param token to transfer
	 * @param to wallet address
	 * @param tokenId of the ERC721 token to transfer
	 */
	function _transferERC721(IERC721 token, address payable to, uint256 tokenId) private { token.safeTransferFrom(address(this), to, tokenId); }

	/**
	* @dev Implementation of the {IERC165} interface.
	* @param interfaceId to check
	* @return true if the interfaceId is supported and false if it is not
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Receiver) returns (bool) {
		return interfaceId == type(IERC721Receiver).interfaceId || 
			interfaceId == type(KnowsBestPony).interfaceId || 
			interfaceId == type(Ownable).interfaceId || 
			interfaceId == type(RecoverableEther).interfaceId || 
			super.supportsInterface(interfaceId);
	}
}