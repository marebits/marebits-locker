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
	 * @param unlockTime after which held tokens can be withdrawn (in seconds after UNIX epoch)
	 */
	struct Account {
		uint256 amount;
		// string metadata;
		address tokenContract;
		uint256 tokenId;
		TokenType tokenType;
		// string tokenUri;
		uint64 unlockTime;
	}

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

	// function getMetadata(uint256 accountId) external view returns (string memory);

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


	// function getTokenUri(uint256 accountId) external view returns (string memory);

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