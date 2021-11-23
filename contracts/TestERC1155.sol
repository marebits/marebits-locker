// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract TestERC1155 is Ownable, ERC1155 {
	constructor() ERC1155("https://mare.biz/test/") {
		for (uint i = 0; i < 1000; i++) {
			_mint(payable(owner()), i + 1, 1, "");
		}
		_mint(payable(owner()), 0, 1000 ether, "");
	}
}