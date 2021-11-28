// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./MarebitsLockerTokenMetadataBuilder.sol";
import "./Token.sol";

/**
 * @title Account library grouping functions related to an account and the Account.Info struct
 * @author Twifag
 */
library Account {
	using Token for Token.Type;

	/**
	 * @dev Data representing an account or issued token
	 * @param accountId of the account; also, the `tokenId` of the Mare Bits Locker Token
	 * @param amount of tokens held
	 * @param tokenId of tokens held; should always be 0 for locked ERC20 tokens
	 * @param tokenContract of tokens held
	 * @param tokenType of tokens held; see {Token.Type}
	 * @param unlockTime after which held tokens can be withdrawn (in seconds after UNIX epoch)
	 * @param isBurned is true if the token representing this account has been burned; otherwise, false
	 * @param isRedeemed is true when token has been redeemed and account is closed; otherwise, false
	 */
	struct Info {
		uint256 accountId;
		uint256 amount;
		uint256 tokenId;
		address tokenContract;
		Token.Type tokenType;
		uint64 unlockTime;
		bool isBurned;
		bool isRedeemed;
	}

	/**
	 * @dev Internally marks a token as having been burnt by setting the `isBurned` flag
	 * @param self represents an {Account.Info}
	 */
	function burn(Info storage self) internal { self.isBurned = true; }

	/**
	 * @dev Creates a new {Account.Info} instance
	 * @param self a mapping(uint256 => Info) representing a collection of {Account.Info}s
	 * @param accountId representing the new account
	 * @param amount of tokens to lock in locker
	 * @param tokenContract for the token to be locked
	 * @param tokenId of the token to be locked; should always be 0 for locked ERC20 tokens
	 * @param tokenType of token to be locked; see {Token.Type}
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 */
	function create(mapping(uint256 => Info) storage self, uint256 accountId, uint256 amount, address tokenContract, uint256 tokenId, Token.Type tokenType, uint64 unlockTime) internal {
		self[accountId] = Info({ accountId: accountId, amount: amount, tokenId: tokenId, tokenContract: tokenContract, tokenType: tokenType, unlockTime: unlockTime, isBurned: false, isRedeemed: false });
	}

	/**
	 * @dev Gets the account details for the account `accountId`
	 * @param self a mapping(uint256 => Info) representing a collection of {Account.Info}s
	 * @param accountId (also `tokenId`) representing the locked account
	 * @return Account.Info representing `accountId`; see {Account.Info}
	 */
	function get(mapping(uint256 => Info) storage self, uint256 accountId) internal view returns (Info storage) { return self[accountId]; }

	/**
	 * @dev Gets the image URI associated with the account `accountId`
	 * @param self a mapping(uint256 => info) representing a collection of {Account.Info}s
	 * return string representing the image URI associated with the locked account
	 */
	function getImage(Info storage self) internal view returns (string memory) { return MarebitsLockerTokenMetadataBuilder.getImage(self, ""); }

	/**
	 * @param self represents an {Account.Info}
	 * @return string metadata for `self`
	 */
	function getMetadata(Info storage self) internal view returns (string memory) { return MarebitsLockerTokenMetadataBuilder.getMetadata(self); }
	
	/**
	 * @param self represents an {Account.Info}
	 * @return string IPFS token URI for `accountId` metadata
	 */
	function getTokenUri(Info storage self) internal view returns (string memory) { return MarebitsLockerTokenMetadataBuilder.getMetadataUri(self); }

	/**
	 * @param self represents an {Account.Info}
	 * @return bool true if the account is defined; otherwise, false
	 */
	function isDefined(Info storage self) internal view returns (bool) { return self.tokenType.isValid(); }

	/**
	 * @param self represents an {Account.Info}
	 * @return bool true if the account is unlocked; otherwise, false
	 */
	function isUnlocked(Info storage self) internal view returns (bool) { return uint256(self.unlockTime) <= block.timestamp; }

	/**
	 * @dev Marks account `self` as redeemed by setting the `amount` to 0, `isRedeemed` to true, and the `unlockTime` to the current time
	 * @param self represents an {Account.Info}
	 */
	function redeem(Info storage self) internal { (self.amount, self.isRedeemed, self.unlockTime) = (0, true, uint64(block.timestamp)); }

	/**
	 * @dev Updates the amount of tokens locked in this account to `amount`; should only be called during a burn/redemption
	 * @param self represents an {Account.Info}
	 * @param amount new amount of tokens to be locked
	 */
	function setAmount(Info storage self, uint256 amount) internal { self.amount = amount; }

	/**
	 * @dev Updates the unlock time of tokens locked in this account to `unlockTime`
	 * @param self represents an {Account.Info}
	 * @param unlockTime in seconds after UNIX epoch
	 */
	function setUnlockTime(Info storage self, uint64 unlockTime) internal { self.unlockTime = unlockTime; }
}