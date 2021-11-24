// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./ITokenTypeable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title The interface for the Mare Bits Locker Account
 * @author Twifag
 */
interface IMarebitsLockerAccount is IERC165, ITokenTypeable {
	/**
	 * @dev Data representing an account or issued token
	 * @param amount of tokens held
	 * @param tokenContract of tokens held
	 * @param tokenId of tokens held; should always be 0 for locked ERC20 tokens
	 * @param tokenType of tokens held; see {ITokenTypeable.TokenType}
	 * @param isRedeemed is true when token has been redeemed and account is closed; otherwise, false
	 * @param unlockTime after which held tokens can be withdrawn (in seconds after UNIX epoch)
	 */
	struct Account {
		uint256 amount;
		// string metadata;
		address tokenContract;
		uint256 tokenId;
		TokenType tokenType;
		// string tokenUri;
		bool isRedeemed;
		uint64 unlockTime;
	}

	/**
	 * @notice Creates a new {IMarebitsLockerAccount.Account}
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param accountId representing the new account
	 * @param amount of tokens to lock in locker
	 * @param tokenContract for the token to be locked
	 * @param tokenId of the token to be locked; should always be 0 for locked ERC20 tokens
	 * @param tokenType of token to be locked; see {ITokenTypeable.TokenType}
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 */
	function __createAccount(uint256 accountId, uint256 amount, address tokenContract, uint256 tokenId, TokenType tokenType, uint64 unlockTime) external;

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
	function getAccount(uint256 accountId) external view returns (Account memory);

	/**
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return uint256 amount of tokens locked in the account `accountId`
	 */
	function getAmount(uint256 accountId) external view returns (uint256);

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
	 * @return ITokenTypeable.TokenType type of tokens locked in the account `accountId`; see {ITokenTypeable.TokenType}
	 */
	function getTokenType(uint256 accountId) external view returns (TokenType);

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