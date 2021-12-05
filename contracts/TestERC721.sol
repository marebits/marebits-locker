// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestERC721 is Ownable, ERC721 {
	constructor() ERC721("Test ERC721 Token", "TestERC721") {
		for (uint i = 0; i < 10; i++) {
			_safeMint(payable(owner()), i);
		}
	}
}