# Mare Bits Locker

Mare Bits Locker is a way to lock-up your ERC20, ERC721, or ERC1155 tokens and keep them safe from that waifu thief Brad.  The contract issues a non-fungible token (NFT) that represents your deposit and allows whoever owns that token after a pre-determined length of time to withdraw the locked funds.  Once locked, **your tokens cannot be withdrawn until the lock period has expired** no matter what.  So, be careful!

This was originally created to facilitate the locking of liquidity tokens as part of the launch of Mare Bits ($MARE).  For more information on that project, see [https://mare.biz/](https://mare.biz/).  Since I figured it could be of use to some others, I've released the source code here.

This should work for all tokens that implement either the ERC20, ERC721, or ERC1155 interfaces, including ERC777.

I will provide more documentation on how this contract can be used in production here once it is deployed.