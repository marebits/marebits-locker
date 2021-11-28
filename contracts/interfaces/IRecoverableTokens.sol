// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "../libraries/Token.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title The abstract Recoverable Tokens interface
 * @author Twifag
 */
interface IRecoverableTokens is IERC165 {
	/**
	 * @notice Recovers ERC20, ERC721, or ERC1155 tokens accidentally sent to this contract
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param tokenType of token to recover; see {Token.Type}
	 * @param tokenContract address of the token to recover
	 * @param tokenId of the token to recover; should always be 0 for ERC20 tokens
	 */
	function __recoverTokens(Token.Type tokenType, address tokenContract, uint256 tokenId) external;
}