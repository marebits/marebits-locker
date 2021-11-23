// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./interfaces/IMarebitsLocker.sol";
import "./interfaces/IMarebitsLockerAccount.sol";
import "./KnowsBestPony.sol";
import "./MarebitsLockerAccount.sol";
import "./MarebitsLockerToken.sol";
import "./MarebitsVault.sol";
import "./RecoverableEther.sol";
import "./RecoverableTokens.sol";
import "./TokenTypeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @title The implementation for the Mare Bits Locker
 * @author Twifag
 */
contract MarebitsLocker is ERC165, TokenTypeable, RecoverableEther, RecoverableTokens, KnowsBestPony, ReentrancyGuard, IMarebitsLocker {
	using Address for address;
	using SafeERC20 for IERC20;

	/** @dev The {MarebitsLockerAccount} contract */
	MarebitsLockerAccount private immutable _lockerAccount;

	/** @dev The {MarebitsLockerToken} contract, representing the token issued when tokens are locked */
	MarebitsLockerToken private immutable _lockerToken;

	/** @dev The {MarebitsVault} where all tokens (ERC20, ERC721, and ERC1155) are held in escrow while locked */
	MarebitsVault private immutable _vault;

	/** @dev Only humans can interact */
	modifier onlyHuman() {
		require(!_msgSender().isContract(), "Caller cannot be a smart contract");
		_;
	}

	/**
	 * @param name of the {MarebitsLockerToken}
	 * @param symbol of the {MarebitsLockerToken}
	 * @param baseURI initially set for the {MarebitsLockerToken}
	 */
	constructor(string memory name, string memory symbol, string memory baseURI) {
		_lockerAccount = new MarebitsLockerAccount();
		_lockerToken = new MarebitsLockerToken(name, symbol, baseURI);
		_vault = new MarebitsVault();
	}

	/**
	 * @notice Recovers ether accidentally sent to this contract or the contracts owned by this one ({MarebitsLockerAccount}, {MarebitsLockerToken}, and {MarebitsVault})
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @inheritdoc RecoverableEther
	 */
	function __recoverEther() public override(RecoverableEther) payable onlyOwner {
		_lockerAccount.__recoverEther();
		_lockerToken.__recoverEther();
		_vault.__recoverEther();
		super.__recoverEther();
	}

	/**
	 * @notice Recovers ERC20, ERC721, or ERC1155 tokens accidentally sent to this contract or the non-vault contracts owned by this one ({MarebitsLockerAccount} and {MarebitsLockerToken})
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @inheritdoc RecoverableTokens
	 */
	function __recoverTokens(TokenType tokenType, address tokenContract, uint256 tokenId) public override(RecoverableTokens) onlyOwner {
		_lockerAccount.__recoverTokens(tokenType, tokenContract, tokenId);
		_lockerToken.__recoverTokens(tokenType, tokenContract, tokenId);
		super.__recoverTokens(tokenType, tokenContract, tokenId);
	}

	/**
	 * @notice Sets the {MarebitsLockerToken.__baseURI}
	 * @dev Only callable by the {Ownable.owner} of this contract
	 * @param baseURI for the {MarebitsLockerToken}
	 */
	function __setBaseURI(string calldata baseURI) external onlyOwner { _lockerToken.__setBaseURI(baseURI); }

	// function __setTokenURI(uint256 tokenId, string calldata tokenUri) external onlyOwner { _lockerToken.__setTokenURI(tokenId, tokenUri); }
	
	/**
	 * @dev Gets a new `accountId` and creates a new {MarebitsLockerAccount}
	 * @param amount of tokens to lock in locker
	 * @param tokenContract for the token to be locked
	 * @param tokenId of the token to be locked; should always be 0 for locked ERC20 tokens
	 * @param tokenType of token to be locked; see {ITokenTypeable.TokenType}
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 * @return accountId for the newly created account
	 */
	function _createAccount(uint256 amount, address tokenContract, uint256 tokenId, TokenType tokenType, uint64 unlockTime) private returns (uint256 accountId) {
		accountId = _lockerToken.__getNextTokenId();
		_lockerAccount.__createAccount(accountId, amount, tokenContract, tokenId, tokenType, unlockTime);
	}

	/**
	 * @dev Issues a new token by calling {MarebitsLockerToken#__issueToken}
	 * @param accountId (also `tokenId`) representing the locked account
	 */
	function _issueToken(uint256 accountId) private {
		// _lockerToken.__issueToken(payable(_msgSender()), accountId, _lockerAccount.getTokenUri(accountId));
		_lockerToken.__issueToken(payable(_msgSender()), accountId);
	}

	/**
	 * @dev Locks ERC1155 tokens in a Mare Bits Locker and issues a redeemable Mare Bits Locker Token that can be used to unlock the tokens after the time `unlockTime` has passed
	 * @param token to be locked
	 * @param tokenId of the token to be locked
	 * @param amount of tokens to lock in locker
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 * @return accountId (also `tokenId`) representing the locked account
	 */
	function _lockERC1155(IERC1155 token, uint256 tokenId, uint256 amount, uint64 unlockTime) private returns (uint256 accountId) {
		require(amount > 0, "`amount` must be > 0");
		require(token.balanceOf(_msgSender(), tokenId) >= amount, "`amount` must be <= total token balance");
		require(token.isApprovedForAll(_msgSender(), address(this)), "Not approved, you must call `token.setApprovalForAll()`");
		accountId = _createAccount(amount, address(token), tokenId, TokenType.ERC1155, unlockTime);
		token.safeTransferFrom(_msgSender(), payable(address(_vault)), tokenId, amount, "");
		_issueToken(accountId);
		emit TokensLocked(accountId, _msgSender(), amount, address(token), tokenId, TokenType.ERC1155, unlockTime);
	}

	/**
	 * @dev Locks ERC20 tokens in a Mare Bits Locker and issues a redeemable Mare Bits Locker Token that can be used to unlock the tokens after the time `unlockTime` has passed
	 * @param token to be locked
	 * @param amount of tokens to lock in locker
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 * @return accountId (also `tokenId`) representing the locked account
	 */
	function _lockERC20(IERC20 token, uint256 amount, uint64 unlockTime) private returns (uint256 accountId) {
		require(amount > 0, "`amount` must be > 0");
		require(token.balanceOf(_msgSender()) >= amount, "`amount` must be <= total token balance");
		require(token.allowance(_msgSender(), address(this)) >= amount, "Not approved, you must call `token.approve()`");
		accountId = _createAccount(amount, address(token), 0, TokenType.ERC20, unlockTime);
		token.safeTransferFrom(_msgSender(), payable(address(_vault)), amount);
		_issueToken(accountId);
		emit TokensLocked(accountId, _msgSender(), amount, address(token), 0, TokenType.ERC20, unlockTime);
	}

	/**
	 * @dev Locks ERC721 tokens in a Mare Bits Locker and issues a redeemable Mare Bits Locker Token that can be used to unlock the tokens after the time `unlockTime` has passed
	 * @param token to be locked
	 * @param tokenId of the token to be locked
	 * @param unlockTime after which locked tokens can be withdrawn (in seconds after UNIX epoch)
	 * @return accountId (also `tokenId`) representing the locked account
	 */
	function _lockERC721(IERC721 token, uint256 tokenId, uint64 unlockTime) private returns (uint256 accountId) {
		require(token.ownerOf(tokenId) == _msgSender(), "`tokenId` not owned by caller");
		require(token.getApproved(tokenId) == address(this), "Not approved, you must call `token.approve()`");
		accountId = _createAccount(1, address(token), tokenId, TokenType.ERC721, unlockTime);
		token.safeTransferFrom(_msgSender(), payable(address(_vault)), tokenId);
		_issueToken(accountId);
		emit TokensLocked(accountId, _msgSender(), 1, address(token), tokenId, TokenType.ERC721, unlockTime);
	}

	/// @inheritdoc IMarebitsLocker
	function balanceOf(uint256 accountId) external view returns (uint256) { return _lockerAccount.getAmount(accountId); }

	/// @inheritdoc IMarebitsLocker
	function extendLock(uint256 accountId, uint64 unlockTime) external onlyHuman {
		require(_lockerToken.__exists(accountId), "Token for `accountId` does not exist");
		require(_lockerToken.ownerOf(accountId) == _msgSender(), "Not the owner of this `accountId`");
		require(unlockTime > _lockerAccount.getUnlockTime(accountId), "New `unlockTime` must be > the existing `unlockTime`");
		_lockerAccount.__setUnlockTime(accountId, unlockTime);
		emit TokensLocked(accountId, _msgSender(), _lockerAccount.getAmount(accountId), _lockerAccount.getTokenContract(accountId), _lockerAccount.getTokenId(accountId), _lockerAccount.getTokenType(accountId), unlockTime);
	}

	/// @inheritdoc IMarebitsLocker
	function getAccount(uint256 accountId) external view returns (IMarebitsLockerAccount.Account memory) { return _lockerAccount.getAccount(accountId); }

	/// @inheritdoc IMarebitsLocker
	function lockTokens(TokenType tokenType, address tokenContract, uint256 tokenId, uint256 amount, uint64 unlockTime) external nonReentrant onlyHuman isValidTokenType(tokenType) returns (uint256) {
		require(uint256(unlockTime) > block.timestamp, "`unlockTime` must be in the future");

		if (tokenType == TokenType.ERC1155) {
			return _lockERC1155(IERC1155(tokenContract), tokenId, amount, unlockTime);
		} else if (tokenType == TokenType.ERC20) {
			return _lockERC20(IERC20(tokenContract), amount, unlockTime);
		} else if (tokenType == TokenType.ERC721) {
			return _lockERC721(IERC721(tokenContract), tokenId, unlockTime);
		} else {
			return 0;
		}
	}

	/// @inheritdoc IMarebitsLocker
	function ownerOf(uint256 accountId) external view returns (address) { return _lockerToken.ownerOf(accountId); }

	/// @inheritdoc IMarebitsLocker
	function redeemToken(uint256 accountId) external nonReentrant onlyHuman {
		require(_lockerToken.__exists(accountId), "Token for `accountId` does not exist");
		require(_lockerToken.ownerOf(accountId) == _msgSender(), "Not the owner of this `accountId`");
		require(_lockerAccount.isUnlocked(accountId), "`unlockTime` not expired");
		require(_lockerAccount.getAmount(accountId) > 0, "Account has no balance");
		_lockerAccount.__setAmount(accountId, 0);
		_lockerToken.__burn(accountId);
		_vault.__transfer(_lockerAccount.getTokenType(accountId), _lockerAccount.getTokenContract(accountId), payable(_msgSender()), _lockerAccount.getTokenId(accountId), _lockerAccount.getAmount(accountId));
		emit TokenRedeemed(accountId, _msgSender(), _lockerAccount.getAmount(accountId), _lockerAccount.getTokenContract(accountId), _lockerAccount.getTokenId(accountId), _lockerAccount.getTokenType(accountId));
	}

	/**
	* @dev Implementation of the {IERC165} interface.
	* @inheritdoc ERC165
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
		return interfaceId == type(KnowsBestPony).interfaceId || 
			interfaceId == type(Ownable).interfaceId || 
			interfaceId == type(RecoverableEther).interfaceId ||
			interfaceId == type(RecoverableTokens).interfaceId || 
			interfaceId == type(IMarebitsLocker).interfaceId || 
			super.supportsInterface(interfaceId);
	}
}