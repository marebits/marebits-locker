// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

interface IMarebitsLockerToken is IERC721Metadata {
	function burn(uint256 tokenId) external;
}