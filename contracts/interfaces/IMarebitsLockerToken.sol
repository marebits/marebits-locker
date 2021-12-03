// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./IRecoverable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

/**
 * @title The interface for the Mare Bits Locker Token
 * @author Twifag
 */
interface IMarebitsLockerToken is IERC721Metadata, IRecoverable {
	/**
	 * @notice Emitted when the URI of the token `id` has changed to `value`
	 * @param value of the new token URI
	 * @param id of the token
	 */
	event URI(string value, uint256 indexed id);

	/**
	 * @notice Thrown when attempting to transfer a token the caller does not own or is not approved to transfer
	 * @param tokenId for the token that is attempting to be transferred
	 */
	error NotApprovedOrOwner(uint256 tokenId);

	/**
	 * @notice Thrown when attempting to make a call that only the owner of this contract's owner can make
	 * @param claimedOwner of the token
	 * @param actualOwner of the token
	 */
	error NotLockerOwner(address claimedOwner, address actualOwner);

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
	 * @dev Only callable by the {Ownable.owner} of this contract's owner
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
	 * @notice Gets the image URI for token `tokenId`
	 * @param tokenId of the token for which you want the image URI
	 * @return imageUri string token image URI
	 */
	// function imageURI(uint256 tokenId) external view returns (string memory imageUri);

	/**
	 * @notice Returns the URI for the token ID `tokenId`
	 * @dev see {ERC1155.uri}
	 * @param tokenId of the token for which to retreive metadata
	 * @return string metadata for the token
	 */
	// function uri(uint256 tokenId) external view returns (string memory);
}