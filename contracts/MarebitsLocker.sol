// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./interfaces/IMarebitsLocker.sol";
import "./interfaces/IMarebitsLockerAccount.sol";
import "./interfaces/IMarebitsLockerToken.sol";
import "./interfaces/IMarebitsVault.sol";
import "./interfaces/IRecoverableEther.sol";
import "./interfaces/IRecoverableTokens.sol";
import "./KnowsBestPony.sol";
import "./libraries/Account.sol";
import "./libraries/Token.sol";
import "./MarebitsLockerAccount.sol";
import "./MarebitsLockerToken.sol";
import "./MarebitsVault.sol";
import "./Recoverable.sol";
import "./OwnershipTransferrable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title The implementation for the Mare Bits Locker
 * @author Twifag
 */
contract MarebitsLocker is OwnershipTransferrable, Recoverable, KnowsBestPony, ReentrancyGuard, IMarebitsLocker {
	using SafeERC20 for IERC20;
	using Token for Token.Type;

	/** @dev the maximum value for time */
	uint64 private constant MAXIMUM_TIME = (2 << 63) - 1;

	/// @dev {IMarebitsLockerAccount} associated with this {IMarebitsLocker}
	IMarebitsLockerAccount public immutable accounts;

	/// @dev {IMarebitsLockerToken} associated with this {IMarebitsLocker}
	IMarebitsLockerToken private immutable lockerToken;

	/** @dev Address of the Mare Bits Token contract */
	IERC20 private immutable mareBitsToken;

	/// @dev {IMarebitsVault} associated with this {IMarebitsLocker}
	IMarebitsVault private immutable vault;

	/**
	 * @dev Must pass a non-zero amount
	 * @param amount that must be greater than zero
	 */
	modifier nonZeroAmount(uint256 amount) {
		if (amount == 0) {
			revert ZeroAmountGiven();
		}
		_;
	}

	/** @dev Only humans can interact */
	modifier onlyHuman() {
		address account = _msgSender();
		uint256 size;

		assembly {
			size := extcodesize(account)
		}

		if (size > 0) {
			revert InvalidCaller();
		}
		_;
	}

	/** @dev Caller must have $MARE to interact with this locker */
	modifier mareHodlerOnly() {
		if (mareBitsToken.balanceOf(_msgSender()) == 0) {
			revert NeedsMoreMARE(_msgSender());
		}
		_;
	}

	/**
	 * @param name of the {MarebitsLockerToken}
	 * @param symbol of the {MarebitsLockerToken}
	 * @param baseURI initially set for the {MarebitsLockerToken}
	 */
	constructor(string memory name, string memory symbol, string memory baseURI, IERC20 mareBitsToken_) {
		accounts = new MarebitsLockerAccount();
		lockerToken = new MarebitsLockerToken(name, symbol, baseURI);
		mareBitsToken = mareBitsToken_;
		vault = new MarebitsVault();
	}

	/** @notice In the case of child contracts somehow receiving ether, this lets us recover it from them.  Do not send ether to any of these contracts, please! */
	receive() external payable {}

	/// @inheritdoc IMarebitsLocker
	function __burn(uint256 accountId) external {
		if (_msgSender() != address(lockerToken)) {
			revert InvalidCaller();
		}
		accounts.__burn(accountId);
	}

	/**
	 * @notice Recovers ether accidentally sent to this contract or the contracts owned by this one ({MarebitsLockerAccount}, {MarebitsLockerToken}, and {MarebitsVault})
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @inheritdoc RecoverableEther
	 */
	function __recoverEther() public override(IRecoverableEther, RecoverableEther) payable onlyOwner {
		accounts.__recoverEther();
		lockerToken.__recoverEther();
		vault.__recoverEther();
		super.__recoverEther();
	}

	/**
	 * @notice Recovers ERC20, ERC721, or ERC1155 tokens accidentally sent to this contract or the non-vault contracts owned by this one ({MarebitsLockerAccount} and {MarebitsLockerToken})
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @inheritdoc RecoverableTokens
	 */
	function __recoverTokens(Token.Type tokenType, address tokenContract, uint256 tokenId) public override(IRecoverableTokens, RecoverableTokens) onlyOwner {
		accounts.__recoverTokens(tokenType, tokenContract, tokenId);
		lockerToken.__recoverTokens(tokenType, tokenContract, tokenId);
		super.__recoverTokens(tokenType, tokenContract, tokenId);
	}

	/**
	 * @dev Checks if an account exists and reverts if it does not
	 * @param accountId for account to check
	 */
	function _checkAccountExists(uint256 accountId) private view {
		if (!lockerToken.__exists(accountId)) {
			revert NonexistentAccount(accountId);
		}
	}

	/**
	 * @dev Checks if approval has been received to transfer a token and reverts if not
	 * @param isApproved is true when approval has been received; otherwise, false
	 * @param tokenAddress of the token for which approval is being requested to transfer
	 * @param approvalFunction that needs to be called in order to grant approval
	 */
	function _checkApproval(bool isApproved, address tokenAddress, string memory approvalFunction) private pure {
		if (!isApproved) {
			revert UnapprovedTokenTransfer(tokenAddress, approvalFunction);
		}
	}

	/**
	 * @dev Checks if the token is owned by the address `claimedOwner` and reverts if not
	 * @param tokenId of the token to check
	 * @param claimedOwner address that is claiming ownership of the token
	 * @param actualOwner address of the actual owner of the token
	 */
	function _checkOwner(uint256 tokenId, address claimedOwner, address actualOwner) private pure {
		if (claimedOwner != actualOwner) {
			revert NotTokenOwner(tokenId, claimedOwner, actualOwner);
		}
	}

	/**
	 * @dev Checks if there is sufficient balance and reverts if not
	 * @param required balance
	 * @param available balance
	 */
	function _checkSufficientBalance(uint256 required, uint256 available) private pure {
		if (required > available) {
			revert InsufficientBalance(required, available);
		}
	}

	/**
	 * @dev Checks if the time `given` falls within the bounds of `maximum` and `minimum` and reverts if not
	 * @param given time (in seconds since UNIX epoch)
	 * @param minimum time bound (in seconds since UNIX epoch)
	 * @param maximum time bound (in seconds since UNIX epoch)
	 */
	function _checkTimeBounds(uint64 given, uint64 minimum, uint64 maximum) private pure {
		if (given < minimum || given > maximum) {
			revert TimeOutOfBounds(given, minimum, maximum);
		}
	}

	/**
	 * @dev Checks if the given token type is valid and reverts if not
	 * @param tokenType to check
	 */
	function _checkTokenType(Token.Type tokenType) private pure {
		if (!tokenType.isValid()) {
			revert InvalidTokenType(tokenType);
		}
	}
	
	/**
	 * @dev Gets a new `accountId` and creates a new {MarebitsLockerAccount}
	 * @param amount of tokens to lock in locker
	 * @param tokenContract for the token to be locked
	 * @param tokenId of the token to be locked; should always be 0 for locked ERC20 tokens
	 * @param tokenType of token to be locked; see {Token.Type}
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 * @return accountId for the newly created account
	 */
	function _createAccount(uint256 amount, address tokenContract, uint256 tokenId, Token.Type tokenType, uint64 unlockTime) private returns (uint256 accountId) {
		if (tokenType == Token.Type.ERC721 && amount > 1) {
			revert InvalidAmount("`amount` must be 1 for ERC721");
		}
		accountId = lockerToken.__getNextTokenId();
		accounts.__createAccount(accountId, amount, tokenContract, tokenId, tokenType, unlockTime);
	}

	/**
	 * @dev Issues a new token by calling {MarebitsLockerToken#__issueToken}
	 * @param accountId (also `tokenId`) representing the locked account
	 */
	function _issueToken(uint256 accountId) private { lockerToken.__issueToken(payable(_msgSender()), accountId); }

	/**
	 * @dev Locks ERC1155 tokens in a Mare Bits Locker and issues a redeemable Mare Bits Locker Token that can be used to unlock the tokens after the time `unlockTime` has passed
	 * @param token to be locked
	 * @param tokenId of the token to be locked
	 * @param amount of tokens to lock in locker
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 * @return accountId (also `tokenId`) representing the locked account
	 */
	function _lockERC1155(IERC1155 token, uint256 tokenId, uint256 amount, uint64 unlockTime) private nonZeroAmount(amount) returns (uint256 accountId) {
		_checkSufficientBalance(amount, token.balanceOf(_msgSender(), tokenId));
		_checkApproval(token.isApprovedForAll(_msgSender(), address(this)), address(token), "setApprovalForAll()");
		accountId = _createAccount(amount, address(token), tokenId, Token.Type.ERC1155, unlockTime);
		token.safeTransferFrom(_msgSender(), payable(address(vault)), tokenId, amount, "");
		_issueToken(accountId);
		emit TokensLocked(accountId, _msgSender(), amount, address(token), tokenId, Token.Type.ERC1155, unlockTime);
	}

	/**
	 * @dev Locks ERC20 tokens in a Mare Bits Locker and issues a redeemable Mare Bits Locker Token that can be used to unlock the tokens after the time `unlockTime` has passed
	 * @param token to be locked
	 * @param amount of tokens to lock in locker
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 * @return accountId (also `tokenId`) representing the locked account
	 */
	function _lockERC20(IERC20 token, uint256 amount, uint64 unlockTime) private nonZeroAmount(amount) returns (uint256 accountId) {
		_checkSufficientBalance(amount, token.balanceOf(_msgSender()));
		_checkApproval(token.allowance(_msgSender(), address(this)) >= amount, address(token), "approve()");
		accountId = _createAccount(amount, address(token), 0, Token.Type.ERC20, unlockTime);
		token.safeTransferFrom(_msgSender(), payable(address(vault)), amount);
		_issueToken(accountId);
		emit TokensLocked(accountId, _msgSender(), amount, address(token), 0, Token.Type.ERC20, unlockTime);
	}

	/**
	 * @dev Locks ERC721 tokens in a Mare Bits Locker and issues a redeemable Mare Bits Locker Token that can be used to unlock the tokens after the time `unlockTime` has passed
	 * @param token to be locked
	 * @param tokenId of the token to be locked
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 * @return accountId (also `tokenId`) representing the locked account
	 */
	function _lockERC721(IERC721 token, uint256 tokenId, uint64 unlockTime) private returns (uint256 accountId) {
		_checkOwner(tokenId, _msgSender(), token.ownerOf(tokenId));
		_checkApproval(token.getApproved(tokenId) == address(this), address(token), "approve()");
		accountId = _createAccount(1, address(token), tokenId, Token.Type.ERC721, unlockTime);
		token.safeTransferFrom(_msgSender(), payable(address(vault)), tokenId);
		_issueToken(accountId);
		emit TokensLocked(accountId, _msgSender(), 1, address(token), tokenId, Token.Type.ERC721, unlockTime);
	}

	/// @inheritdoc IMarebitsLocker
	function extendLock(uint256 accountId, uint64 unlockTime) external nonReentrant onlyHuman mareHodlerOnly returns (uint256) {
		_checkAccountExists(accountId);
		_checkOwner(accountId, _msgSender(), lockerToken.ownerOf(accountId));
		Account.Info memory account = accounts.getAccount(accountId);
		_checkTimeBounds(unlockTime, account.unlockTime, MAXIMUM_TIME);
		accounts.__setUnlockTime(accountId, unlockTime);
		emit TokensLocked(accountId, _msgSender(), account.amount, account.tokenContract, account.tokenId, account.tokenType, unlockTime);
		return accountId;
	}

	/// @inheritdoc IMarebitsLocker
	function getAccount(uint256 accountId) external view returns (Account.Info memory) { return accounts.getAccount(accountId); }

	/// @inheritdoc IMarebitsLocker
	function lockTokens(Token.Type tokenType, address tokenContract, uint256 tokenId, uint256 amount, uint64 unlockTime) external nonReentrant onlyHuman mareHodlerOnly returns (uint256) {
		_checkTokenType(tokenType);
		_checkTimeBounds(unlockTime, uint64(block.timestamp), MAXIMUM_TIME);

		if (tokenType == Token.Type.ERC1155) {
			return _lockERC1155(IERC1155(tokenContract), tokenId, amount, unlockTime);
		} else if (tokenType == Token.Type.ERC20) {
			return _lockERC20(IERC20(tokenContract), amount, unlockTime);
		} else if (tokenType == Token.Type.ERC721) {
			return _lockERC721(IERC721(tokenContract), tokenId, unlockTime);
		} else {
			return 0;
		}
	}

	/// @inheritdoc IMarebitsLocker
	function redeemToken(uint256 accountId) external nonReentrant onlyHuman mareHodlerOnly {
		Account.Info memory account = accounts.getAccount(accountId);

		if (uint256(account.unlockTime) > block.timestamp) {
			revert LockedAccount(account.unlockTime, uint64(block.timestamp));
		}
		_checkAccountExists(accountId);
		_checkOwner(accountId, _msgSender(), lockerToken.ownerOf(accountId));
		_checkSufficientBalance(1, account.amount);
		accounts.__redeem(accountId);
		lockerToken.__burn(accountId);
		vault.__transfer(account.tokenType, account.tokenContract, payable(_msgSender()), account.tokenId, account.amount);
		emit TokenRedeemed(accountId, _msgSender(), account.amount, account.tokenContract, account.tokenId, account.tokenType);
	}

	/**
	* @dev Implementation of the {IERC165} interface.
	* @inheritdoc ERC165
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, OwnershipTransferrable, Recoverable) returns (bool) {
		return interfaceId == type(IMarebitsLocker).interfaceId || 
			interfaceId == type(KnowsBestPony).interfaceId || 
			OwnershipTransferrable.supportsInterface(interfaceId) || 
			Recoverable.supportsInterface(interfaceId);
	}
}