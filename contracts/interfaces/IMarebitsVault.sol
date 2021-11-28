// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "../libraries/Token.sol";
import "./IRecoverableEther.sol";

/**
 * @title The interface for the Mare Bits Vault
 * @author Twifag
 */
interface IMarebitsVault is IRecoverableEther {
	/**
	 * @notice Transfers tokens out of this contract and to the original owner
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param tokenType of token to be transferred; see {Token.Type}
	 * @param tokenContract for the token to be transferred
	 * @param to wallet address
	 * @param tokenId of the token to be transferred; should always be 0 for locked ERC20 tokens
	 * @param amount of tokens to be transferred
	 */
	function __transfer(Token.Type tokenType, address tokenContract, address payable to, uint256 tokenId, uint256 amount) external;
}