# Mare Bits Locker

[Mare Bits Locker](https://locker.mare.biz/) is a way to lock-up your [ERC20](https://eips.ethereum.org/EIPS/eip-20), [ERC721](https://eips.ethereum.org/EIPS/eip-721), or [ERC1155](https://eips.ethereum.org/EIPS/eip-1155) tokens and keep them safe from that waifu thief Brad.  The contract issues a non-fungible token (NFT) that represents your deposit and allows whoever owns that token after a pre-determined length of time to withdraw the locked funds.  Once locked, ***your tokens cannot be withdrawn until the lock period has expired*** no matter what.  So, be careful!

This was created to facilitate the locking of liquidity tokens as part of the launch of Mare Bits ($MARE).  For more information on that project, see [https://mare.biz/](https://mare.biz/).  In order to make the code easily reviewable by others, I've released it here.

This should work for all tokens that implement either the [ERC20](https://eips.ethereum.org/EIPS/eip-20), [ERC721](https://eips.ethereum.org/EIPS/eip-721), or [ERC1155](https://eips.ethereum.org/EIPS/eip-1155) interfaces, including [ERC777](https://eips.ethereum.org/EIPS/eip-777).

## Deployment
Here are the deployed contract addresses:

* Mainnet:
  - Mare Bits Locker: (TBD)
  - Mare Bits Locker Account: (TBD)
  - Mare Bits Locker Token: (TBD)
  - Mare Bits Vault: (TBD)

* Ropsten (test network):
  - Mare Bits Locker: (TBD)
  - Mare Bits Locker Account: (TBD)
  - Mare Bits Locker Token: (TBD)
  - Mare Bits Vault: (TBD)

## Using the deployed contracts
Interaction will primarily be with the Mare Bits Locker, Mare Bits Locker Account, and Mare Bits Locker Token contracts.  The Mare Bits Vault contract just holds deposits and doesn't offer much public functionality.

### Mare Bits Locker
`balanceOf(uint256 accountId) returns (uint256)`
: Returns the number of tokens locked in the account `accountId`.  Keep in mind that for most fungible tokens, a single token will be represented by the value 10^18.

(TBD)

### Mare Bits Locker Account
(TBD)

### Mare Bits Locker Token
(TBD)

### Mare Bits Vault
(TBD)

Term
: Definition