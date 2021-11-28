// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./interfaces/IMarebitsLockerAccount.sol";
import "./interfaces/IMarebitsLockerToken.sol";
import "./interfaces/IOwnable.sol";
import "./KnowsBestPony.sol";
import "./Ownable.sol";
import "./Recoverable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title The implementation for the Mare Bits Locker Token
 * @author Twifag
 */
contract MarebitsLockerToken is Recoverable, ERC721Enumerable, KnowsBestPony, IMarebitsLockerToken {
	using Strings for uint256;

	/** @dev The base URI for computing the {ERC721#tokenURI}, roundabout way of overriding {ERC721#_baseURI} */
	string private __baseURI;

	/** @dev Optional mapping for image URIs */
	mapping(uint256 => string) private _imageURIs;

	/** @dev uint256 to keep track of the tokens as they are created */
	uint256 private _tokenIdTracker;

	/** @dev Optional mapping for token URIs */
	mapping(uint256 => string) private _tokenURIs;

	/** @dev Require that the caller is the same address as the owner of this contract's owner */
	modifier onlyLockerOwner() {
		address lockerOwner = IOwnable(owner()).owner();

		if (lockerOwner != _msgSender()) {
			revert NotLockerOwner(_msgSender(), lockerOwner);
		}
		_;
	}

	/**
	 * @param name of this token
	 * @param symbol of this token
	 * @param baseURI initially set for this token
	 */
	constructor(string memory name, string memory symbol, string memory baseURI) ERC721(name, symbol) { __baseURI = baseURI; }

	/// @inheritdoc IMarebitsLockerToken
	function __burn(uint256 tokenId) external onlyOwner { _burn(tokenId); }

	/// @inheritdoc IMarebitsLockerToken
	function __exists(uint256 tokenId) external view onlyOwner returns (bool) { return _exists(tokenId); }

	/// @inheritdoc IMarebitsLockerToken
	function __getNextTokenId() external onlyOwner returns (uint256 tokenId) { return _tokenIdTracker++; }

	/// @inheritdoc IMarebitsLockerToken
	function __issueToken(address payable owner, uint256 tokenId) external onlyOwner { _safeMint(owner, tokenId); }

	/// @inheritdoc IMarebitsLockerToken
	function __setBaseURI(string calldata baseURI) external onlyLockerOwner { __baseURI = baseURI; }

	/** @return string the `__baseURI` */
	function _baseURI() internal view override returns (string memory) { return __baseURI; }

	/** 
	 * @param path of the URI
	 * @param suffix of the URI
	 * @return string the generated URI by combining `__baseURI`, `path`, and `suffix` */
	function _generateURI(string memory path, string memory suffix) private view returns (string memory) { return string(abi.encodePacked(_baseURI(), path, suffix)); }

	/**
	 * @dev Marks the {IMarebitsLockerAccount.Account} as being burned and frees up storage, see {ERC721Enumerable}
	 * @inheritdoc ERC721
	 */
	function _burn(uint256 tokenId) internal override {
		IMarebitsLockerAccount(owner()).__burn(tokenId);
		delete _imageURIs[tokenId];
		delete _tokenURIs[tokenId];
		super._burn(tokenId);
	}

	/// @inheritdoc ERC721
	function _mint(address to, uint256 tokenId) internal override {
		emit URI(tokenURI(tokenId), tokenId);
		super._mint(to, tokenId);
	}

	/// @inheritdoc IMarebitsLockerToken
	function burn(uint256 tokenId) external {
		if (!_isApprovedOrOwner(_msgSender(), tokenId)) {
			revert NotApprovedOrOwner(tokenId);
		}
		_burn(tokenId);
	}

	/// @inheritdoc IMarebitsLockerToken
	function imageURI(uint256 tokenId) external view returns (string memory imageUri) {
		imageUri = _imageURIs[tokenId];

		if (bytes(imageUri).length == 0) {
			imageUri = _generateURI(tokenId.toString(), ".svg");
		}
	}

	/// @inheritdoc IMarebitsLockerToken
	function setImageURI(uint256 tokenId, string memory imageUri) public onlyLockerOwner { _imageURIs[tokenId] = imageUri; }

	/// @inheritdoc IMarebitsLockerToken
	function setTokenURI(uint256 tokenId, string memory tokenUri) public onlyLockerOwner {
		_tokenURIs[tokenId] = tokenUri;
		emit URI(tokenUri, tokenId);
	}

	/**
	* @dev Implementation of the {IERC165} interface.
	* @inheritdoc ERC165
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721Enumerable, Recoverable) returns (bool) {
		return interfaceId == type(IMarebitsLockerToken).interfaceId || 
			interfaceId == type(KnowsBestPony).interfaceId || 
			interfaceId == type(Recoverable).interfaceId || 
			interfaceId == type(IERC721Metadata).interfaceId || 
			ERC721Enumerable.supportsInterface(interfaceId) || 
			Recoverable.supportsInterface(interfaceId);
	}

	/// @inheritdoc ERC721
	function tokenURI(uint256 tokenId) public view override(ERC721, IERC721Metadata) returns (string memory tokenUri) {
		tokenUri = _tokenURIs[tokenId];

		if (bytes(tokenUri).length == 0) {
			tokenUri = _generateURI(tokenId.toString(), ".json");
		}
	}

	/// @inheritdoc IMarebitsLockerToken
	function uri(uint256 tokenId) external view returns (string memory) { return tokenURI(tokenId); }
}