// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./IMarebitsLockerAccount.sol";
import "./IMarebitsLockerToken.sol";
import "./IMarebitsVault.sol";
import "./IOwnershipTransferrable.sol";
import "./IRecoverable.sol";
import "../libraries/Account.sol";
import "../libraries/Token.sol";

/**
 * @title The interface for the Mare Bits Locker
 * @author Twifag
 */
interface IMarebitsLocker is IOwnershipTransferrable, IRecoverable {
	/**
	 * @notice Emitted when a token is locked or the lock on a token is extended
	 * @param accountId (also `tokenId`) representing the locked account
	 * @param owner contract address
	 * @param amount locked in locker
	 * @param tokenContract for the locked token
	 * @param tokenId of the locked token; should always be 0 for locked ERC20 tokens
	 * @param tokenType of token locked; see {Token.Type}
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 */
	event TokensLocked(uint256 indexed accountId, address indexed owner, uint256 amount, address tokenContract, uint256 tokenId, Token.Type tokenType, uint64 unlockTime);

	/**
	 * @notice Emitted after a Mare Bits Locker Token is redeemed for its locked tokens
	 * @param accountId (also `tokenId`) representing the locked account
	 * @param owner contract address
	 * @param amount locked in locker
	 * @param tokenContract for the locked token
	 * @param tokenId of the locked token; should always be 0 for locked ERC20 tokens
	 * @param tokenType of token locked; see {Token.Type}
	 */
	event TokenRedeemed(uint256 indexed accountId, address indexed owner, uint256 amount, address tokenContract, uint256 tokenId, Token.Type tokenType);

	/**
	 * @notice Thrown when the required balance is less than the available balance
	 * @param required balance
	 * @param available balance
	 */
	error InsufficientBalance(uint256 required, uint256 available);

	/** @notice Thrown when called by an invalid caller (such as a contract) */
	error InvalidCaller();

	/**
	 * @notice Thrown when the given token type `tokenType` is not valid.  Must be 1 for ERC1155, 2 for ERC20, or 3 for ERC721
	 * @param tokenType of the token to check
	 */
	error InvalidTokenType(Token.Type tokenType);

	/** 
	 * @notice Thrown when attempting to redeem a token for an account that is still locked
	 * @param expiresAt time when the lock expires (in seconds since UNIX epoch)
	 * @param currentTime (in seconds since UNIX epoch)
	 */
	error LockedAccount(uint64 expiresAt, uint64 currentTime);

	/**
	 * @notice Thrown when the account does not exist
	 * @param accountId of the account that does not exists
	 */
	error NonexistentAccount(uint256 accountId);

	/**
	 * @notice Thrown when attempting to transfer a token the caller does not own
	 * @param tokenId for the token that is attempting to be transferred
	 * @param claimedOwner of the token
	 * @param actualOwner of the token
	 */
	error NotTokenOwner(uint256 tokenId, address claimedOwner, address actualOwner);

	/**
	 * @notice Thrown when a passed time value is out of the stated bounds
	 * @param given time (in seconds since UNIX epoch)
	 * @param minimum time bound (in seconds since UNIX epoch)
	 * @param maximum time bound (in seconds since UNIX epoch)
	 */
	error TimeOutOfBounds(uint64 given, uint64 minimum, uint64 maximum);

	/**
	 * @notice Thrown when the caller has not approved the token transfer
	 * @param tokenAddress that was attempted to be transferred, the function `approvalFunction` should be called on this address
	 * @param approvalFunction that needs to be called to grant approval
	 */
	error UnapprovedTokenTransfer(address tokenAddress, string approvalFunction);

	/** @notice Thrown when a zero amount is passed */
	error ZeroAmountGiven();

	/** @return IMarebitsLockerAccount associated with this {IMarebitsLocker} */
	function accounts() external view returns (IMarebitsLockerAccount);

	/**
	 * @notice Extends the `unlockTime` for a given `accountId`
	 * @dev Emits a {TokensLocked} event
	 * @param accountId (also `tokenId`) representing the locked account
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch, must be greater than existing `unlockTime` value)
	 * @return accountId for the locked tokens
	 */
	function extendLock(uint256 accountId, uint64 unlockTime) external returns (uint256);

	/** @return IMarebitsLockerToken associated with this {IMarebitsLocker} */
	function lockerToken() external view returns (IMarebitsLockerToken);

	/**
	 * @notice Locks tokens in a Mare Bits Locker and issues a redeemable Mare Bits Locker Token that can be used to unlock the tokens after the time `unlockTime` has passed
	 * @dev Emits a {TokensLocked} event
	 * @param tokenType of token to be locked; see {Token.Type}
	 * @param tokenContract for the token to be locked
	 * @param tokenId of the token to be locked; should always be 0 for locked ERC20 tokens
	 * @param amount of tokens to lock in locker
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 * @return accountId for the locked tokens
	 */
	function lockTokens(Token.Type tokenType, address tokenContract, uint256 tokenId, uint256 amount, uint64 unlockTime) external returns (uint256);

	/**
	 * @notice Redeems (burns) a Mare Bits Locker Token and transfers all locked tokens back to the caller
	 * @dev Emits a {TokenRedeemed} event
	 * @param accountId (also `tokenId`) representing the locked account
	 */
	function redeemToken(uint256 accountId) external;

	/** @return IMarebitsVault associated with this {IMarebitsLocker} */
	function vault() external view returns (IMarebitsVault);
}