# Mare Bits Locker

[Mare Bits Locker](https://locker.mare.biz/) is a way to lock-up your [ERC20](https://eips.ethereum.org/EIPS/eip-20), [ERC721](https://eips.ethereum.org/EIPS/eip-721), or [ERC1155](https://eips.ethereum.org/EIPS/eip-1155) tokens and keep them safe from that waifu thief Brad.  The contract issues a non-fungible token (NFT) that represents your deposit and allows whoever owns that token after a pre-determined length of time to withdraw the locked funds.  Once locked, ***your tokens cannot be withdrawn until the lock period has expired*** no matter what.  So, be careful!

This was created to facilitate the locking of liquidity tokens as part of the launch of Mare Bits ($MARE).  For more information on that project, see [https://mare.biz/](https://mare.biz/).  In order to make the code easily reviewable by others, I've released it here.

This should work for all tokens that implement either the [ERC20](https://eips.ethereum.org/EIPS/eip-20), [ERC721](https://eips.ethereum.org/EIPS/eip-721), or [ERC1155](https://eips.ethereum.org/EIPS/eip-1155) interfaces, including [ERC777](https://eips.ethereum.org/EIPS/eip-777).

## Deployment
Here are the deployed contract addresses:

* Ethereum:
  - Mare Bits Locker: (TBD)
  - Mare Bits Locker Account: (TBD)
  - Mare Bits Locker Token: (TBD)
  - Mare Bits Vault: (TBD)

* Polygon:
  - Mare Bits Locker: [0xdFcB170bEa5b1B970574b8cCd0347A095256c4A8](https://polygonscan.com/address/0xdFcB170bEa5b1B970574b8cCd0347A095256c4A8 "View on Polygonscan")
  - Mare Bits Locker Account: [0x7c20bfda6ba2cd5ca85b952696e279a2efcd5ff2](https://polygonscan.com/address/0x7c20bfda6ba2cd5ca85b952696e279a2efcd5ff2 "View on Polygonscan")
  - Mare Bits Locker Token: [0xc12d120e3973e7bac07e1802ca0ea30676451642](https://polygonscan.com/address/0xc12d120e3973e7bac07e1802ca0ea30676451642 "View on Polygonscan")
  - Mare Bits Vault: [0x3d41144b7236fb2119c52546d6f5df15c0c316a8](https://polygonscan.com/address/0x3d41144b7236fb2119c52546d6f5df15c0c316a8 "View on Polygonscan")

* Ropsten (test network):
  - Mare Bits Locker: (TBD)
  - Mare Bits Locker Account: (TBD)
  - Mare Bits Locker Token: (TBD)
  - Mare Bits Vault: (TBD)

## Using the deployed contracts
Interaction will primarily be with the Mare Bits Locker, Mare Bits Locker Account, and Mare Bits Locker Token contracts.  The Mare Bits Vault contract just holds deposits and doesn't offer much public functionality.

### Mare Bits Locker
#### Functions
`accounts() returns (IMarebitsLockerAccount)`
: Returns the address associated with the Mare Bits Locker Account contract.

`bestPony() returns (string)`
: Returns the best pony.

`extendLock(uint256 accountId, uint64 unlockTime) returns (uint256)`
: Sets the lock time for account `accountId` to `unlockTime` (in seconds since UNIX epoch).  The new unlock time must be greater than the existing unlock time for the account (will throw `TimeOutOfBounds` if not).  Emits the `TokensLocked` event and returns the `accountId` when successful.

`getAccount(uint256 accountId) returns (Account.Info)`
: Returns the account details for the account `accountId`.  These details include the `accountId`, the `amount` of tokens locked, the `tokenId` of the token locked, the `tokenContract` address, the `tokenType` locked, the `unlockTime`, whether or not the locker token `isBurned`, and whether or not the locker token `isRedeemed`.

`lockerToken() returns (IMarebitsLockerToken)`
: Returns the address associated with the Mare Bits Locker Token contract.

`lockTokens(Token.Type tokenType, address tokenContract, uint256 tokenId, uint256 amount, uint64 unlockTime) returns (uint256)`
: Locks `amount` tokens of the `tokenType` token deployed at the `tokenContract` address with the token ID `tokenId` for a period represented by `unlockTime` (in seconds since UNIX epoch).  The `tokenId` is ignored for ERC-20 tokens and the `amount` must be `1` for ERC-721 tokens.  Emits the `TokensLocked` event and returns the newly created `accountId` when successful.

`mareBitsToken() returns (IERC20)`
: Returns the address associated with the Mare Bits token contract.  (This function is private in the Polygon contract.)

`redeemToken(uint256 accountId)`
: Redeems the token for the account `accountId`, returning the locked tokens to the owner of `accountId`.  This will throw a `TimeOutOfBounds` error if attempted before `unlockTime` has expired.  Emits the `TokenRedeemed` event when successful.

`supportsInterface(bytes4 interfaceId) returns (bool)`
: See [ERC-165](https://eips.ethereum.org/EIPS/eip-165#how-a-contract-will-publish-the-interfaces-it-implements).

`vault() returns (IMarebitsVault)`
: Returns the address associated with the Mare Bits Vault contract.

#### Events
`TokensLocked(uint256 indexed accountId, address indexed owner, uint256 amount, address tokenContract, uint256 tokenId, Token.Type tokenType, uint64 unlockTime)`
: Emitted whenever a new locker is created or whenever the `unlockTime` for an existing locker has been extended.

`TokenRedeemed(uint256 indexed accountId, address indexed owner, uint256 amount, address tokenContract, uint256 tokenId, Token.Type tokenType)`
: Emitted whenever a locker token is redeemed and the deposited tokens are returned to the `owner`.

#### Errors
`InsufficientBalance(uint256 required, uint256 available)`
: Thrown when the required balance is less than the available balance.

`InvalidAmount(string reason)`
: Thrown when an invalid amount is entered.  The `reason` should contain the reason why the amount was invalid.

`InvalidCaller()`
: Thrown when called by an invalid caller (such as a contract instead of a real wallet).

`InvalidTokenType(Token.Type tokenType)`
: Thrown when the `tokenType` is not valid.  Must be 1 for ERC-1155, 2 for ERC-20, or 3 for ERC-721.

`LockedAccount(uint64 expiresAt, uint64 currentTime)`
: Thrown when attempting to call `redeemToken` for an account that is still locked.  `expiresAt` is the time when the lock expires (in seconds since UNIX epoch) and `currentTime` is the current block time stamp (in seconds since UNIX epoch).

`NeedsMoreMARE(address wallet)`
: Thrown when someone attempts to interact with this contract who does not hodl $MARE.  You must have a balance greater than 0.

`NonexistentAccount(uint256 accountId)`
: Thrown when the account `accountId` doesn't exist.

`NotTokenOwner(uint256 tokenId, address claimedOwner, address actualOwner)`
: Thrown when attempting to lock the token `tokenId` by `claimedOwner` when the actual owner is `actualOwner`.

`TimeOutOfBounds(uint64 given, uint64 minimum, uint64 maximum)`
: Thrown when the `given` time does not fall within the range specified by `minimum` and `maximum`.

`UnapprovedTokenTransfer(address tokenAddress, string approvalFunction)`
: Thrown when attempting to transfer tokens for token contract `tokenAddress`.  The `approvalFunction` tells you what function needs to be run on the `tokenAddress` contract to approve the transfer.

`ZeroAmountGiven()`
: Thrown when a zero amount is passed.

### Mare Bits Locker Account
#### Data Types
`Token.Type`
: Is an enumerated value represented internally as a `uint8` where:
    - `0` means `UNDEFINED`
    - `1` means `ERC-1155`
    - `2` means `ERC-20`
    - `3` means `ERC-721`

`Account.Info`
: Is a data structure (or object) with the following members:
    `uint256 accountId`
    : The account ID

    `uint256 amount`
    : The amount of tokens locked in the account

    `uint256 tokenId`
    : The token ID for the tokens locked in the account (only meaningful for ERC-1155 and ERC-721 tokens, will be 0 for ERC-20 tokens)

    `address tokenContract`
    : The address of the token contract for the locked tokens

    `uint64 unlockTime`
    : The time after which the account token can be redeemed to withdraw the locked token balance (in seconds since UNIX epoch)

    `bool isBurned`
    : True when the account token has been burned; otherwise, false

    `bool isRedeemed`
    : True when the tokens locked by the account have been redeemed; otherwise, false

#### Functions
`bestPony() returns (string)`
: Returns the best pony.

`getAccount(uint256 accountId) returns (Account.Info)`
: Returns the account details for the account `accountId`.  These details include the `accountId`, the `amount` of tokens locked, the `tokenId` of the token locked, the `tokenContract` address, the `tokenType` locked, the `unlockTime`, whether or not the locker token `isBurned`, and whether or not the locker token `isRedeemed`.

`supportsInterface(bytes4 interfaceId) returns (bool)`
: See [ERC-165](https://eips.ethereum.org/EIPS/eip-165#how-a-contract-will-publish-the-interfaces-it-implements).

#### Errors
`NonexistentAccount(uint256 accountId)`
: Thrown when the account `accountId` doesn't exist.

### Mare Bits Locker Token
This contract represents the ERC-721 token issued when tokens are locked.  As such, it extends all the functions and events from the [ERC-721 specification](https://eips.ethereum.org/EIPS/eip-721#specification).

#### Functions
`approve(address to, uint256 tokenId)`
: Gives permission to `to` to transfer token `tokenId` to another account.  The approval is cleared when the token is transferred.  Only a single account can be approved at a time, so approving the [zero address](https://etherscan.io/address/0x0000000000000000000000000000000000000000) clears previous approvals.  Emits an `Approval` event when successful.

`balanceOf(address owner) returns (uint256)`
: Returns the number of Mare Bits Locker tokens held by address `owner`.

`bestPony() returns (string)`
: Returns the best pony.

`burn(uint256 tokenId)`
: Can only be called by the owner of the token `tokenId` or someone the owner has approved.  This will burn the locker token, in effect sending it to the [zero address](https://etherscan.io/address/0x0000000000000000000000000000000000000000).  If this is called, the token will disappear and any tokens locked in the locker will be unredeemable!  Emits a `Transfer` event when successful.

`getApproved(uint256 tokenId) returns (address)`
: Returns the account approved to transfer token `tokenId`.

`isApprovedForAll(address owner, address operator) returns (bool)`
: Returns true if the `operator` is allowed to manage all of the assets of `owner`.

`name() returns (string)`
: Returns the general name of this token (Mare Bits Locker Token).

`ownerOf(uint256 tokenId) returns (address)`
: Returns the address that owns the token `tokenId`.

`safeTransferFrom(address from, address to, uint256 tokenId)`
: Safely transfers token `tokenId` from `from` to `to`, checking first that contract recipients are aware of the ERC-721 protocol to prevent tokens from being forever locked.  Emits a `Transfer` event when successful.

`setApprovalForAll(address operator, bool _approved)`
: Approve or remove `operator` as an operator for the caller.  Operators can call `transferFrom` or `safeTransferFrom` for any token owned by the caller.  Emits an `ApprovalForAll` event when successful.

`supportsInterface(bytes4 interfaceId) returns (bool)`
: See [ERC-165](https://eips.ethereum.org/EIPS/eip-165#how-a-contract-will-publish-the-interfaces-it-implements).

`symbol() returns (string)`
: Returns the general symbol of this token (🐎‍♀️🔒🪙).

`tokenByIndex(uint256 index) returns (uint256)`
: REturns a token ID at a given `index` of all Mare Bit Locker Tokens.  Use along with `totalSupply` to enumerate all tokens.

`tokenOfOwnerByIndex(address owner, uint256 index) returns (uint256)`
: Returns a token ID owned by `owner` at a given `index` of its token list.  Use along with `balanceOf` to enumerate all of `owner`'s tokens.

`tokenURI(uint256 tokenId)`
: Returns the URI containing metadata for the token `tokenId`.  This is used by sites to display metadata for this NFT.

`totalSupply() returns (uint256)`
: Returns the total amount of Mare Bit Locker Tokens.

`transferFrom(address from, address to, uint256 tokenId)`
: Transfers token `tokenId` from `from` to `to`.  Emits a `Transfer` event when successful.

#### Events
`Approval(address owner, address approved, uint256 tokenId)`
: Emitted when `owner` enabled `approved` to manager the token `tokenId`.

`ApprovalForAll(address owner, address operator, bool approved)`
: Emitted when `owner` enables or disables (`approved`) `operator` to manager all of its assets.

`Transfer(address from, address to, uint256 tokenId)`
: Emitted when token `tokenId` is transferred from `from` to `to`.

`URI(string value, uint256 indexed id)`
: Emitted when the URI of the token `id` has changed to `value`.

#### Errors
`NotApprovedOrOwner(uint256 tokenId)`
: Thrown when attempted to transfer a token the caller does not own or is not approved to transfer.

`NotLockerOwner(address claimedOwner, address actualOwner)`
: Thrown when attempted to make a call that only the owner of this contract's owner can make.

### Mare Bits Vault
#### Functions
`bestPony() returns (string)`
: Returns the best pony.

`onERC1155BatchReceived(address operator, address from, uint256[] ids, uint256[] values, bytes data) returns (bytes4)`
: Handles the receipt of multiple ERC-1155 token types.  This function is called at the end of a `safeBatchTransferFrom` after the balances have been updated.  It returns its Solidity selector to confirm the token transfers.

`onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes data) returns (bytes4)`
: Handles the receipt of a single ERC-1155 token type.  This function is called at the end of a `safeTransferFrom` after the balance has been updated.  It returns its Solidity selector to confirm the token transfer.

`onERC721Received(address operator, address from, uint256 tokenId, bytes data) returns (bytes4)`
: Whenever an ERC-721 `tokenId` is transferred to this contract via `safeTransferFrom` by `operator` from `from`, this function is called.  It returns its Solidity selector to confirm the token transfer.

`supportsInterface(bytes4 interfaceId) returns (bool)`
: See [ERC-165](https://eips.ethereum.org/EIPS/eip-165#how-a-contract-will-publish-the-interfaces-it-implements).