// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./interfaces/IMarebitsLockerAccount.sol";
import "./interfaces/IMarebitsLockerToken.sol";
import "./KnowsBestPony.sol";
import "./Ownable.sol";
import "./Recoverable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title The implementation for the Mare Bits Locker Token
 * @author Twifag
 */
contract MarebitsLockerToken is Recoverable, ERC721Enumerable, KnowsBestPony, IMarebitsLockerToken {
	/** @dev The base URI for computing the {ERC721#tokenURI}, roundabout way of overriding {ERC721#_baseURI} */
	string private __baseURI;

	/** @dev uint256 to keep track of the tokens as they are created */
	uint256 private _tokenIdTracker;

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
	function __setBaseURI(string calldata baseURI) external onlyOwner { __baseURI = baseURI; }

	/** @return string the `__baseURI` */
	function _baseURI() internal view override returns (string memory) { return __baseURI; }

	/**
	 * @dev Marks the {IMarebitsLockerAccount.Account} as being burned, see {ERC721Enumerable}
	 */
	function _burn(uint256 tokenId) internal override {
		IMarebitsLockerAccount(owner()).__burn(tokenId);
		super._burn(tokenId);
	}

	/// @inheritdoc IMarebitsLockerToken
	function burn(uint256 tokenId) external {
		if (!_isApprovedOrOwner(_msgSender(), tokenId)) {
			revert NotApprovedOrOwner(tokenId);
		}
		_burn(tokenId);
	}

	/// @inheritdoc IMarebitsLockerToken
	function getMetadata(uint256 tokenId) external view returns (string memory) { return IMarebitsLockerAccount(owner()).getMetadata(tokenId); }

	/// @inheritdoc IMarebitsLockerToken
	function imageURI(uint256 tokenId) external view returns (string memory) { return IMarebitsLockerAccount(owner()).getImage(tokenId); }

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
	function tokenURI(uint256 tokenId) public view override(ERC721, IERC721Metadata) returns (string memory) { return IMarebitsLockerAccount(owner()).getTokenUri(tokenId); }

	/// @inheritdoc IMarebitsLockerToken
	function uri(uint256 tokenId) external view returns (string memory) { return tokenURI(tokenId); }
}