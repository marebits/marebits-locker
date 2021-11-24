// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./interfaces/IMarebitsLockerAccount.sol";
import "./interfaces/IMarebitsLockerToken.sol";
import "./KnowsBestPony.sol";
import "./RecoverableEther.sol";
import "./RecoverableTokens.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title The implementation for the Mare Bits Locker Token
 * @author Twifag
 */
contract MarebitsLockerToken is RecoverableEther, RecoverableTokens, ERC721Enumerable, KnowsBestPony, IMarebitsLockerToken {
	using Counters for Counters.Counter;

	/** @dev The base URI for computing the {ERC721#tokenURI}, roundabout way of overriding {ERC721#_baseURI} */
	string private __baseURI;

	/** @dev {IMarebitsLockerAccount} associated with this token */
	IMarebitsLockerAccount private _lockerAccount;

	/** @dev {Counters} to keep track of the tokens as they are created */
	Counters.Counter private _tokenIdTracker;

	/**
	 * @param name of this token
	 * @param symbol of this token
	 * @param baseURI initially set for this token
	 */
	constructor(string memory name, string memory symbol, string memory baseURI, IMarebitsLockerAccount lockerAccount) ERC721(name, symbol) { (__baseURI, _lockerAccount) = (baseURI, lockerAccount); }

	/// @inheritdoc IMarebitsLockerToken
	function __burn(uint256 tokenId) external onlyOwner { _burn(tokenId); }

	/// @inheritdoc IMarebitsLockerToken
	function __exists(uint256 tokenId) external view onlyOwner returns (bool) { return _exists(tokenId); }

	/// @inheritdoc IMarebitsLockerToken
	function __getNextTokenId() external onlyOwner returns (uint256 tokenId) {
		tokenId = _tokenIdTracker.current();
		_tokenIdTracker.increment();
	}

	/// @inheritdoc IMarebitsLockerToken
	// function __issueToken(address payable owner, uint256 tokenId, string memory tokenUri) external onlyOwner {
	function __issueToken(address payable owner, uint256 tokenId) external onlyOwner {
		_safeMint(owner, tokenId);
		// _setTokenURI(tokenId, tokenUri);
	}

	/// @inheritdoc IMarebitsLockerToken
	function __setBaseURI(string calldata baseURI) external onlyOwner { __baseURI = baseURI; }

	// function __setTokenURI(uint256 tokenId, string calldata tokenUri) external onlyOwner { _setTokenURI(tokenId, tokenUri); }

	/** @return string the `__baseURI` */
	function _baseURI() internal view override returns (string memory) { return __baseURI; }

	/// @inheritdoc IMarebitsLockerToken
	function burn(uint256 tokenId) external {
		require(_isApprovedOrOwner(_msgSender(), tokenId), "Not approved or owner");
		_burn(tokenId);
	}

	/**
	* @dev Implementation of the {IERC165} interface.
	* @inheritdoc ERC165
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721Enumerable) returns (bool) {
		return interfaceId == type(ERC721Burnable).interfaceId || 
			interfaceId == type(IMarebitsLockerToken).interfaceId || 
			interfaceId == type(KnowsBestPony).interfaceId || 
			interfaceId == type(Ownable).interfaceId || 
			interfaceId == type(RecoverableEther).interfaceId ||
			interfaceId == type(RecoverableTokens).interfaceId || 
			// interfaceId == type(ERC721URIStorage).interfaceId || 
			super.supportsInterface(interfaceId);
	}

	/// @inheritdoc ERC721
	function tokenURI(uint256 tokenId) public view override(ERC721, IERC721Metadata) returns (string memory) { return _lockerAccount.getTokenUri(tokenId); }

	/// @inheritdoc IMarebitsLockerToken
	function uri(uint256 tokenId) external view returns (string memory) { return tokenURI(tokenId); }
}