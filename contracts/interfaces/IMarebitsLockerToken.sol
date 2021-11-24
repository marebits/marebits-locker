// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

/**
 * @title The interface for the Mare Bits Locker Token
 * @author Twifag
 */
interface IMarebitsLockerToken is IERC721Metadata {
	/**
	 * @notice Burns the given token `tokenId`
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param tokenId of the token to burn/destroy
	 */
	function __burn(uint256 tokenId) external;

	/**
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param tokenId to check
	 * @return bool true if the token `tokenId` exists; otherwise, false
	 */
	function __exists(uint256 tokenId) external view returns (bool);

	/**
	 * @notice Gets the next token `tokenId` or `accountId`, incrementing the counter `_tokenIdTracker`
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @return tokenId of the next token ID
	 */
	function __getNextTokenId() external returns (uint256 tokenId);

	/**
	 * @notice Issues a new token to the address `owner` for the token `tokenId`
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param owner of the newly issued token
	 * @param tokenId to be issued
	 */
	function __issueToken(address payable owner, uint256 tokenId) external;

	/**
	 * @notice Sets the `__baseURI`
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param baseURI that will be set as the new baseURI
	 */
	function __setBaseURI(string calldata baseURI) external;

	/**
	 * @notice Destroys token `tokenId`.  See {ERC721._burn}
	 * @dev Only callable by the {Ownable.owner} of the implementing contract
	 * @param tokenId of the token to burn/destroy
	 */
	function burn(uint256 tokenId) external;

	/**
	 * @notice Returns the URI for the token ID `tokenId`
	 * @dev see {ERC1155.uri}
	 * @param tokenId of the token for which to retreive metadata
	 * @return string metadata for the token
	 */
	function uri(uint256 tokenId) external view returns (string memory);
}