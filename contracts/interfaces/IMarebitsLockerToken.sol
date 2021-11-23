// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

/**
 * @title The interface for the Mare Bits Locker Token
 * @author Twifag
 */
interface IMarebitsLockerToken is IERC721Metadata {
	/**
	 * @notice Destroys token `tokenId`.  See {ERC721._burn}
	 * @dev Only callable by the {Ownable.owner} of the implementing contract
	 * @param tokenId of the token to burn/destroy
	 */
	function burn(uint256 tokenId) external;
}