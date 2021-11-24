// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./ITokenTypeable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title The interface for the Mare Bits Vault
 * @author Twifag
 */
interface IMarebitsVault is IERC165, ITokenTypeable {
	/**
	 * @notice Transfers tokens out of this contract and to the original owner
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param tokenType of token to be transferred; see {ITokenTypeable.TokenType}
	 * @param tokenContract for the token to be transferred
	 * @param to wallet address
	 * @param tokenId of the token to be transferred; should always be 0 for locked ERC20 tokens
	 * @param amount of tokens to be transferred
	 */
	function __transfer(TokenType tokenType, address tokenContract, address payable to, uint256 tokenId, uint256 amount) external;
}