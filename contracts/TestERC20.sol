// SPDX-License-Identifier: LicenseRef-DSPL
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is Ownable, ERC20 {
	constructor() ERC20("Test ERC20 Token", "Test\\ERC<20") { _mint(payable(owner()), 1000 ether); }
}