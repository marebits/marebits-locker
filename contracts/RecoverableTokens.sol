// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./interfaces/IRecoverableTokens.sol";
import "./libraries/Token.sol";
import "./Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title The abstract Recoverable Tokens contract
 * @author Twifag
 */
abstract contract RecoverableTokens is Ownable, IRecoverableTokens {
	using SafeERC20 for IERC20;

	/**
	 * @dev Recovers ERC1155 tokens accidentally sent to this contract
	 * @param token to recover
	 * @param tokenId to recover
	 */
	function __recoverERC1155(IERC1155 token, uint256 tokenId) internal {
		uint256 balance = token.balanceOf(address(this), tokenId);
		token.safeTransferFrom(address(this), payable(owner()), tokenId, balance, "");
	}

	/**
	 * @dev Recovers ERC20 tokens accidentally sent to this contract
	 * @param token to recover
	 */
	function __recoverERC20(IERC20 token) internal {
		uint256 balance = token.balanceOf(address(this));
		token.safeTransfer(payable(owner()), balance);
	}

	/**
	 * @dev Recovers ERC721 tokens accidentally sent to this contract
	 * @param token to recover
	 * @param tokenId to recover
	 */
	function __recoverERC721(IERC721 token, uint256 tokenId) internal { token.safeTransferFrom(address(this), payable(owner()), tokenId); }

	/// @inheritdoc IRecoverableTokens
	function __recoverTokens(Token.Type tokenType, address tokenContract, uint256 tokenId) public virtual onlyOwner {
		if (tokenType == Token.Type.ERC1155) {
			__recoverERC1155(IERC1155(tokenContract), tokenId);
		} else if (tokenType == Token.Type.ERC20) {
			__recoverERC20(IERC20(tokenContract));
		} else if (tokenType == Token.Type.ERC721) {
			__recoverERC721(IERC721(tokenContract), tokenId);
		}
	}

	/**
	* @dev Implementation of the {IERC165} interface.
	* @inheritdoc ERC165
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, Ownable) returns (bool) {
		return interfaceId == type(IRecoverableTokens).interfaceId || 
			super.supportsInterface(interfaceId);
	}
}