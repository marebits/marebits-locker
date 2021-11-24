// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./IMarebitsLockerAccount.sol";
import "./ITokenTypeable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title The interface for the Mare Bits Locker
 * @author Twifag
 */
interface IMarebitsLocker is IERC165, ITokenTypeable {
	/**
	 * @notice Emitted when a token is locked or the lock on a token is extended
	 * @param accountId (also `tokenId`) representing the locked account
	 * @param owner contract address
	 * @param amount locked in locker
	 * @param tokenContract for the locked token
	 * @param tokenId of the locked token; should always be 0 for locked ERC20 tokens
	 * @param tokenType of token locked; see {ITokenTypeable.TokenType}
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 */
	event TokensLocked(uint256 indexed accountId, address indexed owner, uint256 amount, address tokenContract, uint256 tokenId, TokenType tokenType, uint64 unlockTime);

	/**
	 * @notice Emitted after a Mare Bits Locker Token is redeemed for its locked tokens
	 * @param accountId (also `tokenId`) representing the locked account
	 * @param owner contract address
	 * @param amount locked in locker
	 * @param tokenContract for the locked token
	 * @param tokenId of the locked token; should always be 0 for locked ERC20 tokens
	 * @param tokenType of token locked; see {ITokenTypeable.TokenType}
	 */
	event TokenRedeemed(uint256 indexed accountId, address indexed owner, uint256 amount, address tokenContract, uint256 tokenId, TokenType tokenType);

	/**
	 * @notice Sets the {MarebitsLockerToken.__baseURI}
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param baseURI for the {MarebitsLockerToken}
	 */
	function __setBaseURI(string calldata baseURI) external;

	/**
	 * @notice Extends the `unlockTime` for a given `accountId`
	 * @dev Emits a {TokensLocked} event
	 * @param accountId (also `tokenId`) representing the locked account
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch, must be greater than existing `unlockTime` value)
	 * @return accountId for the locked tokens
	 */
	function extendLock(uint256 accountId, uint64 unlockTime) external returns (uint256);

	/**
	 * @notice Gets the account details for the account `accountId`
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return IMarebitsLockerAccount.Account representing `accountId`; see {IMarebitsLockerAccount.Account}
	 */
	function getAccount(uint256 accountId) external view returns (IMarebitsLockerAccount.Account memory);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return string metadata for `accountId`
	 */
	function getMetadata(uint256 accountId) external view returns (string memory);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return string IPFS token URI for `accountId` metadata
	 */
	function getTokenUri(uint256 accountId) external view returns (string memory);

	/**
	 * @notice Locks tokens in a Mare Bits Locker and issues a redeemable Mare Bits Locker Token that can be used to unlock the tokens after the time `unlockTime` has passed
	 * @dev Emits a {TokensLocked} event
	 * @param tokenType of token to be locked; see {ITokenTypeable.TokenType}
	 * @param tokenContract for the token to be locked
	 * @param tokenId of the token to be locked; should always be 0 for locked ERC20 tokens
	 * @param amount of tokens to lock in locker
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 * @return accountId for the locked tokens
	 */
	function lockTokens(TokenType tokenType, address tokenContract, uint256 tokenId, uint256 amount, uint64 unlockTime) external returns (uint256);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return address of the owner of the account `accountId`
	 */
	function ownerOf(uint256 accountId) external view returns (address);

	/**
	 * @notice Redeems (burns) a Mare Bits Locker Token and transfers all locked tokens back to the caller
	 * @dev Emits a {TokenRedeemed} event
	 * @param accountId (also `tokenId`) representing the locked account
	 */
	function redeemToken(uint256 accountId) external;
}