// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "../libraries/Account.sol";
import "../libraries/Token.sol";
import "./IRecoverable.sol";

/**
 * @title The interface for the Mare Bits Locker Account
 * @author Twifag
 */
interface IMarebitsLockerAccount is IRecoverable {
	/**
	 * @notice Thrown when an invalid amount is entered
	 * @param reason amount is invalid
	 */
	error InvalidAmount(string reason);

	/**
	 * @notice Thrown when the account does not exist
	 * @param accountId of the account that does not exists
	 */
	error NonexistentAccount(uint256 accountId);

	/**
	 * @notice Thrown when a passed time value is out of the stated bounds
	 * @param given time (in seconds since UNIX epoch)
	 * @param minimum time bound (in seconds since UNIX epoch)
	 * @param maximum time bound (in seconds since UNIX epoch)
	 */
	error TimeOutOfBounds(uint64 given, uint64 minimum, uint64 maximum);

	/** @notice Thrown when a zero amount is passed */
	error ZeroAmountGiven();

	/**
	 * @notice Internally marks a token as having been burnt by setting the `isBurned` flag in the {IMarebitsLockerAccount.Account}
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param accountId representing the account being burned
	 */
	function __burn(uint256 accountId) external;

	/**
	 * @notice Creates a new {IMarebitsLockerAccount.Account}
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param accountId representing the new account
	 * @param amount of tokens to lock in locker
	 * @param tokenContract for the token to be locked
	 * @param tokenId of the token to be locked; should always be 0 for locked ERC20 tokens
	 * @param tokenType of token to be locked; see {Token.Type}
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 */
	function __createAccount(uint256 accountId, uint256 amount, address tokenContract, uint256 tokenId, Token.Type tokenType, uint64 unlockTime) external;

	/**
	 * @notice Marks account `accountId` as redeemed by setting the `amount` to 0, `isRedeemed` to true, and the `unlockTime` to the current time
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param accountId representing the account to redeem
	 */
	function __redeem(uint256 accountId) external;

	/**
	 * @notice Updates the amount of tokens locked in this account to `amount`; should only be called during a burn/redemption
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param accountId representing the account
	 * @param amount new amount of tokens to be locked
	 */
	function __setAmount(uint256 accountId, uint256 amount) external;

	/**
	 * @notice Updates the unlock time of tokens locked in this account to `unlockTime`; called by {IMarebitsLocker.extendLock}
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param accountId representing the account
	 * @param unlockTime in seconds after UNIX epoch
	 */
	function __setUnlockTime(uint256 accountId, uint64 unlockTime) external;

	/**
	 *  @notice Gets the account details for the account `accountId`
	 *  @param accountId (also `tokenId`) representing the locked account
	 *  @return Account representing `accountId`; see {IMarebitsLockerAccount.Account}
	 */
	function getAccount(uint256 accountId) external view returns (Account.Info memory);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return uint256 amount of tokens locked in the account `accountId`
	 */
	function getAmount(uint256 accountId) external view returns (uint256);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return string the image URI representing the tokens locked in the account `accountId`
	 */
	function getImage(uint256 accountId) external view returns (string memory);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return string metadata for `accountId`
	 */
	function getMetadata(uint256 accountId) external view returns (string memory);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return address token contract address for the tokens locked in the account `accountId`
	 */
	function getTokenContract(uint256 accountId) external view returns (address);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return Token.Type type of tokens locked in the account `accountId`; see {Token.Type}
	 */
	function getTokenType(uint256 accountId) external view returns (Token.Type);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return uint256 token ID of the tokens locked in the account `accountId`
	 */
	function getTokenId(uint256 accountId) external view returns (uint256);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return string IPFS token URI for `accountId` metadata
	 */
	function getTokenUri(uint256 accountId) external view returns (string memory);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return uint256 time after which tokens locked in the account `accountId` can be withdrawn (in seconds after UNIX epoch)
	 */
	function getUnlockTime(uint256 accountId) external view returns (uint64);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return bool true if the account exists; otherwise, false
	 */
	function hasAccount(uint256 accountId) external view returns (bool);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return bool true if the `unlockTime` has expired for the account `accountId`; otherwise, false
	 */
	function isUnlocked(uint256 accountId) external view returns (bool);
}