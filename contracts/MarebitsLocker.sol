// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./interfaces/IMarebitsLocker.sol";
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

contract MarebitsLocker is ERC165, TokenTypeable, RecoverableEther, RecoverableTokens, KnowsBestPony, ReentrancyGuard, IMarebitsLocker {
	using Address for address;
	using SafeERC20 for IERC20;

	// account handler
	MarebitsLockerAccount private _lockerAccount;

	// issued locker token contract
	MarebitsLockerToken private _lockerToken;

	// vault where all tokens (ERC20 and ERC721) are held in escrow while locked
	MarebitsVault private _vault;

	/**
	 * @dev Only humans can interact
	 */
	modifier onlyHuman() {
		require(!_msgSender().isContract(), "Caller cannot be a smart contract");
		_;
	}

	constructor(string memory name, string memory symbol, string memory baseURI) {
		_lockerAccount = new MarebitsLockerAccount();
		_lockerToken = new MarebitsLockerToken(name, symbol, baseURI);
		_vault = new MarebitsVault();
	}

	function __recoverEther() public override(RecoverableEther) payable onlyOwner {
		_lockerAccount.__recoverEther();
		_lockerToken.__recoverEther();
		_vault.__recoverEther();
		super.__recoverEther();
	}

	function __recoverTokens(TokenType tokenType, address tokenContract, uint256 tokenId) public override(RecoverableTokens) onlyOwner {
		_lockerAccount.__recoverTokens(tokenType, tokenContract, tokenId);
		_lockerToken.__recoverTokens(tokenType, tokenContract, tokenId);
		super.__recoverTokens(tokenType, tokenContract, tokenId);
	}

	function __setBaseURI(string calldata baseURI) external onlyOwner { _lockerToken.__setBaseURI(baseURI); }

	function __setTokenURI(uint256 tokenId, string calldata tokenUri) external onlyOwner { _lockerToken.__setTokenURI(tokenId, tokenUri); }
	
	function _createAccount(uint256 amount, address tokenContract, uint256 tokenId, TokenType tokenType, uint256 unlockTime) private returns (uint256 issuedTokenId) {
		issuedTokenId = _lockerToken.__getNextTokenId();
		_lockerAccount.__createAccount(issuedTokenId, amount, tokenContract, tokenId, tokenType, unlockTime);
	}

	function _lockERC1155(IERC1155 token, uint256 tokenId, uint256 amount, uint256 unlockTime) private {
		require(amount > 0, "`amount` must be > 0");
		require(token.balanceOf(_msgSender(), tokenId) >= amount, "`amount` must be <= total token balance");
		require(token.isApprovedForAll(_msgSender(), address(this)), "Not approved, you must call `token.setApprovalForAll()`");
		uint256 issuedTokenId = _createAccount(amount, address(token), tokenId, TokenType.ERC1155, unlockTime);
		token.safeTransferFrom(_msgSender(), payable(address(_vault)), tokenId, amount, "");
		_lockerToken.__issueToken(payable(_msgSender()), issuedTokenId, _lockerAccount.getTokenUri(issuedTokenId));
		emit TokensLocked(issuedTokenId, _msgSender(), amount, address(token), tokenId, TokenType.ERC1155, unlockTime);
	}

	function _lockERC20(IERC20 token, uint256 amount, uint256 unlockTime) private {
		require(amount > 0, "`amount` must be > 0");
		require(token.balanceOf(_msgSender()) >= amount, "`amount` must be <= total token balance");
		require(token.allowance(_msgSender(), address(this)) >= amount, "Not approved, you must call `token.approve()`");
		uint256 issuedTokenId = _createAccount(amount, address(token), 0, TokenType.ERC20, unlockTime);
		token.safeTransferFrom(_msgSender(), payable(address(_vault)), amount);
		_lockerToken.__issueToken(payable(_msgSender()), issuedTokenId, _lockerAccount.getTokenUri(issuedTokenId));
		emit TokensLocked(issuedTokenId, _msgSender(), amount, address(token), 0, TokenType.ERC20, unlockTime);
	}

	function _lockERC721(IERC721 token, uint256 tokenId, uint256 unlockTime) private {
		require(token.ownerOf(tokenId) == _msgSender(), "`tokenId` not owned by caller");
		require(token.getApproved(tokenId) == address(this), "Not approved, you must call `token.approve()`");
		uint256 issuedTokenId = _createAccount(1, address(token), tokenId, TokenType.ERC721, unlockTime);
		token.safeTransferFrom(_msgSender(), payable(address(_vault)), tokenId);
		_lockerToken.__issueToken(payable(_msgSender()), issuedTokenId, _lockerAccount.getTokenUri(issuedTokenId));
		emit TokensLocked(issuedTokenId, _msgSender(), 1, address(token), tokenId, TokenType.ERC721, unlockTime);
	}

	function getAccount(uint256 tokenId) external view returns (uint256, string memory, address, uint256, TokenType, string memory, uint256) { return _lockerAccount.getAccount(tokenId); }

	function extendLock(uint256 tokenId, uint256 unlockTime) external onlyHuman {
		require(_lockerToken.__exists(tokenId), "`tokenId` does not exist");
		require(_lockerToken.ownerOf(tokenId) == _msgSender(), "Not the owner of this `tokenId`");
		require(unlockTime > _lockerAccount.getUnlockTime(tokenId), "New `unlockTime` must be > the existing `unlockTime`");
		_lockerAccount.__setUnlockTime(tokenId, unlockTime);
		emit TokensLocked(tokenId, _msgSender(), _lockerAccount.getAmount(tokenId), _lockerAccount.getTokenContract(tokenId), _lockerAccount.getTokenId(tokenId), _lockerAccount.getTokenType(tokenId), unlockTime);
	}

	function lockTokens(TokenType tokenType, address tokenContract, uint256 tokenId, uint256 amount, uint256 unlockTime) external nonReentrant onlyHuman isValidTokenType(tokenType) {
		require(unlockTime > block.timestamp, "`unlockTime` must be in the future");

		if (tokenType == TokenType.ERC1155) {
			_lockERC1155(IERC1155(tokenContract), tokenId, amount, unlockTime);
		} else if (tokenType == TokenType.ERC20) {
			_lockERC20(IERC20(tokenContract), amount, unlockTime);
		} else if (tokenType == TokenType.ERC721) {
			_lockERC721(IERC721(tokenContract), tokenId, unlockTime);
		}
	}

	function redeemToken(uint256 tokenId) external nonReentrant onlyHuman {
		require(_lockerToken.__exists(tokenId), "`tokenId` does not exist");
		require(_lockerToken.ownerOf(tokenId) == _msgSender(), "Not the owner of this `tokenId`");
		require(_lockerToken.getApproved(tokenId) == address(this), "Not approved, you must call `token.approve()`");
		require(_lockerAccount.isUnlocked(tokenId), "`unlockTime` not expired");
		require(_lockerAccount.getAmount(tokenId) > 0, "Account has no balance");
		_lockerAccount.__setAmount(tokenId, 0);
		_lockerToken.__burn(tokenId);
		_vault.__transfer(_lockerAccount.getTokenType(tokenId), _lockerAccount.getTokenContract(tokenId), payable(_msgSender()), _lockerAccount.getTokenId(tokenId), _lockerAccount.getAmount(tokenId));
		emit TokensRedeemed(tokenId, _msgSender(), _lockerAccount.getAmount(tokenId), _lockerAccount.getTokenContract(tokenId), _lockerAccount.getTokenId(tokenId), _lockerAccount.getTokenType(tokenId));
	}

	/**
	* @dev Implementation of the {IERC165} interface.
	* @param interfaceId to check
	* @return true if the interfaceId is supported and false if it is not
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