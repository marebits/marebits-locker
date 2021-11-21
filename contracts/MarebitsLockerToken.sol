// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "./interfaces/IMarebitsLockerToken.sol";
import "./KnowsBestPony.sol";
import "./RecoverableEther.sol";
import "./RecoverableTokens.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MarebitsLockerToken is RecoverableEther, RecoverableTokens, ERC721URIStorage, KnowsBestPony, IMarebitsLockerToken {
	using Counters for Counters.Counter;

	string private __baseURI;

	// count tokens as they're created
	Counters.Counter private _tokenIdTracker;

	constructor(string memory name, string memory symbol, string memory baseURI) ERC721(name, symbol) { __baseURI = baseURI; }

	function __burn(uint256 tokenId) external onlyOwner { _burn(tokenId); }

	function __exists(uint256 tokenId) external view onlyOwner returns (bool) { return _exists(tokenId); }

	function __getNextTokenId() external onlyOwner returns (uint256 tokenId) {
		tokenId = _tokenIdTracker.current();
		_tokenIdTracker.increment();
	}

	function __issueToken(address payable owner, uint256 tokenId, string memory tokenUri) external onlyOwner {
		_safeMint(owner, tokenId);
		_setTokenURI(tokenId, tokenUri);
	}

	function __setBaseURI(string calldata baseURI) external onlyOwner { __baseURI = baseURI; }

	function __setTokenURI(uint256 tokenId, string calldata tokenUri) external onlyOwner { _setTokenURI(tokenId, tokenUri); }

	function _baseURI() internal view override returns (string memory) { return __baseURI; }

	/**
	* @dev Burns `tokenId`. See {ERC721-_burn}.
	*/
	function burn(uint256 tokenId) external {
		require(_isApprovedOrOwner(_msgSender(), tokenId), "Not approved or owner");
		_burn(tokenId);
	}

	/**
	* @dev Implementation of the {IERC165} interface.
	* @param interfaceId to check
	* @return true if the interfaceId is supported and false if it is not
	*/
	function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
		return interfaceId == type(KnowsBestPony).interfaceId || 
			interfaceId == type(Ownable).interfaceId || 
			interfaceId == type(RecoverableEther).interfaceId ||
			interfaceId == type(RecoverableTokens).interfaceId || 
			interfaceId == type(ERC721URIStorage).interfaceId || 
			interfaceId == type(IMarebitsLockerToken).interfaceId || 
			ERC721.supportsInterface(interfaceId);
	}
}