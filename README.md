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
<dl>
<dt><code>accounts() returns (IMarebitsLockerAccount)</code></dt>
<dd>Returns the address associated with the Mare Bits Locker Account contract.</dd>

<dt><code>bestPony() returns (string)</code></dt>
<dd>Returns the best pony.</dd>

<dt><code>extendLock(uint256 accountId, uint64 unlockTime) returns (uint256)</code></dt>
<dd>Sets the lock time for account <code>accountId</code> to <code>unlockTime</code> (in seconds since UNIX epoch).  The new unlock time must be greater than the existing unlock time for the account (will throw <code>TimeOutOfBounds</code> if not).  Emits the <code>TokensLocked</code> event and returns the <code>accountId</code> when successful.</dd>

<dt><code>getAccount(uint256 accountId) returns (Account.Info)</code></dt>
<dd>Returns the account details for the account <code>accountId</code>.  These details include the <code>accountId</code>, the <code>amount</code> of tokens locked, the <code>tokenId</code> of the token locked, the <code>tokenContract</code> address, the <code>tokenType</code> locked, the <code>unlockTime</code>, whether or not the locker token <code>isBurned</code>, and whether or not the locker token <code>isRedeemed</code>.</dd>

<dt><code>lockerToken() returns (IMarebitsLockerToken)</code></dt>
<dd>Returns the address associated with the Mare Bits Locker Token contract.</dd>

<dt><code>lockTokens(Token.Type tokenType, address tokenContract, uint256 tokenId, uint256 amount, uint64 unlockTime) returns (uint256)</code></dt>
<dd>Locks <code>amount</code> tokens of the <code>tokenType</code> token deployed at the <code>tokenContract</code> address with the token ID <code>tokenId</code> for a period represented by <code>unlockTime</code> (in seconds since UNIX epoch).  The <code>tokenId</code> is ignored for ERC-20 tokens and the <code>amount</code> must be <code>1</code> for ERC-721 tokens.  Emits the <code>TokensLocked</code> event and returns the newly created <code>accountId</code> when successful.</dd>

<dt><code>mareBitsToken() returns (IERC20)</code></dt>
<dd>Returns the address associated with the Mare Bits token contract.  (This function is private in the Polygon contract.)</dd>

<dt><code>redeemToken(uint256 accountId)</code></dt>
<dd>Redeems the token for the account <code>accountId</code>, returning the locked tokens to the owner of <code>accountId</code>.  This will throw a <code>TimeOutOfBounds</code> error if attempted before <code>unlockTime</code> has expired.  Emits the <code>TokenRedeemed</code> event when successful.</dd>

<dt><code>supportsInterface(bytes4 interfaceId) returns (bool)</code></dt>
<dd>See <a href="https://eips.ethereum.org/EIPS/eip-165#how-a-contract-will-publish-the-interfaces-it-implements">ERC-165</a>.</dd>

<dt><code>vault() returns (IMarebitsVault)</code></dt>
<dd>Returns the address associated with the Mare Bits Vault contract.</dd>
</dl>

#### Events
<dl>
<dt><code>TokensLocked(uint256 indexed accountId, address indexed owner, uint256 amount, address tokenContract, uint256 tokenId, Token.Type tokenType, uint64 unlockTime)</code></dt>
<dd>Emitted whenever a new locker is created or whenever the <code>unlockTime</code> for an existing locker has been extended.</dd>

<dt><code>TokenRedeemed(uint256 indexed accountId, address indexed owner, uint256 amount, address tokenContract, uint256 tokenId, Token.Type tokenType)</code></dt>
<dd>Emitted whenever a locker token is redeemed and the deposited tokens are returned to the <code>owner</code>.</dd>
</dl>

#### Errors
<dl>
<dt><code>InsufficientBalance(uint256 required, uint256 available)</code></dt>
<dd>Thrown when the required balance is less than the available balance.</dd>

<dt><code>InvalidAmount(string reason)</code></dt>
<dd>Thrown when an invalid amount is entered.  The <code>reason</code> should contain the reason why the amount was invalid.</dd>

<dt><code>InvalidCaller()</code></dt>
<dd>Thrown when called by an invalid caller (such as a contract instead of a real wallet).</dd>

<dt><code>InvalidTokenType(Token.Type tokenType)</code></dt>
<dd>Thrown when the <code>tokenType</code> is not valid.  Must be 1 for ERC-1155, 2 for ERC-20, or 3 for ERC-721.</dd>

<dt><code>LockedAccount(uint64 expiresAt, uint64 currentTime)</code></dt>
<dd>Thrown when attempting to call <code>redeemToken</code> for an account that is still locked.  <code>expiresAt</code> is the time when the lock expires (in seconds since UNIX epoch) and <code>currentTime</code> is the current block time stamp (in seconds since UNIX epoch).</dd>

<dt><code>NeedsMoreMARE(address wallet)</code></dt>
<dd>Thrown when someone attempts to interact with this contract who does not hodl $MARE.  You must have a balance greater than 0.</dd>

<dt><code>NonexistentAccount(uint256 accountId)</code></dt>
<dd>Thrown when the account <code>accountId</code> doesn't exist.</dd>

<dt><code>NotTokenOwner(uint256 tokenId, address claimedOwner, address actualOwner)</code></dt>
<dd>Thrown when attempting to lock the token <code>tokenId</code> by <code>claimedOwner</code> when the actual owner is <code>actualOwner</code>.</dd>

<dt><code>TimeOutOfBounds(uint64 given, uint64 minimum, uint64 maximum)</code></dt>
<dd>Thrown when the <code>given</code> time does not fall within the range specified by <code>minimum</code> and <code>maximum</code>.</dd>

<dt><code>UnapprovedTokenTransfer(address tokenAddress, string approvalFunction)</code></dt>
<dd>Thrown when attempting to transfer tokens for token contract <code>tokenAddress</code>.  The <code>approvalFunction</code> tells you what function needs to be run on the <code>tokenAddress</code> contract to approve the transfer.</dd>

<dt><code>ZeroAmountGiven()</code></dt>
<dd>Thrown when a zero amount is passed.</dd>
</dl>

### Mare Bits Locker Account
#### Data Types
<dl>
<dt><code>Token.Type</code></dt>
<dd>Is an enumerated value represented internally as a <code>uint8</code> where:
<ul>
<li><code>0</code> means <code>UNDEFINED</code></li>
<li><code>1</code> means <code>ERC-1155</code></li>
<li><code>2</code> means <code>ERC-20</code></li>
<li><code>3</code> means <code>ERC-721</code></li>
</ul>
</dd>
<dt><code>Account.Info</code></dt>
<dd>Is a data structure (or object) with the following members:
<dl>
<dt><code>uint256 accountId</code></dt>
<dd>The account ID</dd>

<dt><code>uint256 amount</code></dt>
<dd>The amount of tokens locked in the account</dd>

<dt><code>uint256 tokenId</code></dt>
<dd>The token ID for the tokens locked in the account (only meaningful for ERC-1155 and ERC-721 tokens, will be 0 for ERC-20 tokens)</dd>

<dt><code>address tokenContract</code></dt>
<dd>The address of the token contract for the locked tokens</dd>

<dt><code>uint64 unlockTime</code></dt>
<dd>The time after which the account token can be redeemed to withdraw the locked token balance (in seconds since UNIX epoch)</dd>

<dt><code>bool isBurned</code></dt>
<dd>True when the account token has been burned; otherwise, false</dd>

<dt><code>bool isRedeemed</code></dt>
<dd>True when the tokens locked by the account have been redeemed; otherwise, false</dd>
</dl>
</dd>
</dl>

#### Functions
<dl>
<dt><code>bestPony() returns (string)</code></dt>
<dd>Returns the best pony.</dd>

<dt><code>getAccount(uint256 accountId) returns (Account.Info)</code></dt>
<dd>Returns the account details for the account <code>accountId</code>.  These details include the <code>accountId</code>, the <code>amount</code> of tokens locked, the <code>tokenId</code> of the token locked, the <code>tokenContract</code> address, the <code>tokenType</code> locked, the <code>unlockTime</code>, whether or not the locker token <code>isBurned</code>, and whether or not the locker token <code>isRedeemed</code>.</dd>

<dt><code>supportsInterface(bytes4 interfaceId) returns (bool)</code></dt>
<dd>See <a href="https://eips.ethereum.org/EIPS/eip-165#how-a-contract-will-publish-the-interfaces-it-implements">ERC-165</a>.</dd>
</dl>

#### Errors
<dl>
<dt><code>NonexistentAccount(uint256 accountId)</code></dt>
<dd>Thrown when the account <code>accountId</code> doesn't exist.</dd>
</dl>

### Mare Bits Locker Token
This contract represents the ERC-721 token issued when tokens are locked.  As such, it extends all the functions and events from the [ERC-721 specification](https://eips.ethereum.org/EIPS/eip-721#specification).

#### Functions
<dl>
<dt><code>approve(address to, uint256 tokenId)</code></dt>
<dd>Gives permission to <code>to</code> to transfer token <code>tokenId</code> to another account.  The approval is cleared when the token is transferred.  Only a single account can be approved at a time, so approving the <a href="https://etherscan.io/address/0x0000000000000000000000000000000000000000">zero address</a> clears previous approvals.  Emits an <code>Approval</code> event when successful.</dd>

<dt><code>balanceOf(address owner) returns (uint256)</code></dt>
<dd>Returns the number of Mare Bits Locker tokens held by address <code>owner</code>.</dd>

<dt><code>bestPony() returns (string)</code></dt>
<dd>Returns the best pony.</dd>

<dt><code>burn(uint256 tokenId)</code></dt>
<dd>Can only be called by the owner of the token <code>tokenId</code> or someone the owner has approved.  This will burn the locker token, in effect sending it to the <a href="https://etherscan.io/address/0x0000000000000000000000000000000000000000">zero address</a>.  If this is called, the token will disappear and any tokens locked in the locker will be unredeemable!  Emits a <code>Transfer</code> event when successful.</dd>

<dt><code>getApproved(uint256 tokenId) returns (address)</code></dt>
<dd>Returns the account approved to transfer token <code>tokenId</code>.</dd>

<dt><code>isApprovedForAll(address owner, address operator) returns (bool)</code></dt>
<dd>Returns true if the <code>operator</code> is allowed to manage all of the assets of <code>owner</code>.</dd>

<dt><code>name() returns (string)</code></dt>
<dd>Returns the general name of this token (Mare Bits Locker Token).</dd>

<dt><code>ownerOf(uint256 tokenId) returns (address)</code></dt>
<dd>Returns the address that owns the token <code>tokenId</code>.</dd>

<dt><code>safeTransferFrom(address from, address to, uint256 tokenId)</code></dt>
<dd>Safely transfers token <code>tokenId</code> from <code>from</code> to <code>to</code>, checking first that contract recipients are aware of the ERC-721 protocol to prevent tokens from being forever locked.  Emits a <code>Transfer</code> event when successful.</dd>

<dt><code>setApprovalForAll(address operator, bool _approved)</code></dt>
<dd>Approve or remove <code>operator</code> as an operator for the caller.  Operators can call <code>transferFrom</code> or <code>safeTransferFrom</code> for any token owned by the caller.  Emits an <code>ApprovalForAll</code> event when successful.</dd>

<dt><code>supportsInterface(bytes4 interfaceId) returns (bool)</code></dt>
<dd>See <a href="https://eips.ethereum.org/EIPS/eip-165#how-a-contract-will-publish-the-interfaces-it-implements">ERC-165</a>.</dd>

<dt><code>symbol() returns (string)</code></dt>
<dd>Returns the general symbol of this token (🐎‍♀️🔒🪙).</dd>

<dt><code>tokenByIndex(uint256 index) returns (uint256)</code></dt>
<dd>REturns a token ID at a given <code>index</code> of all Mare Bit Locker Tokens.  Use along with <code>totalSupply</code> to enumerate all tokens.</dd>

<dt><code>tokenOfOwnerByIndex(address owner, uint256 index) returns (uint256)</code></dt>
<dd>Returns a token ID owned by <code>owner</code> at a given <code>index</code> of its token list.  Use along with <code>balanceOf</code> to enumerate all of <code>owner</code>'s tokens.</dd>

<dt><code>tokenURI(uint256 tokenId)</code></dt>
<dd>Returns the URI containing metadata for the token <code>tokenId</code>.  This is used by sites to display metadata for this NFT.</dd>

<dt><code>totalSupply() returns (uint256)</code></dt>
<dd>Returns the total amount of Mare Bit Locker Tokens.</dd>

<dt><code>transferFrom(address from, address to, uint256 tokenId)</code></dt>
<dd>Transfers token <code>tokenId</code> from <code>from</code> to <code>to</code>.  Emits a <code>Transfer</code> event when successful.</dd>
</dl>

#### Events
<dl>
<dt><code>Approval(address owner, address approved, uint256 tokenId)</code></dt>
<dd>Emitted when <code>owner</code> enabled <code>approved</code> to manager the token <code>tokenId</code>.</dd>

<dt><code>ApprovalForAll(address owner, address operator, bool approved)</code></dt>
<dd>Emitted when <code>owner</code> enables or disables (<code>approved</code>) <code>operator</code> to manager all of its assets.</dd>

<dt><code>Transfer(address from, address to, uint256 tokenId)</code></dt>
<dd>Emitted when token <code>tokenId</code> is transferred from <code>from</code> to <code>to</code>.</dd>

<dt><code>URI(string value, uint256 indexed id)</code></dt>
<dd>Emitted when the URI of the token <code>id</code> has changed to <code>value</code>.</dd>
</dl>

#### Errors
<dl>
<dt><code>NotApprovedOrOwner(uint256 tokenId)</code></dt>
<dd>Thrown when attempted to transfer a token the caller does not own or is not approved to transfer.</dd>

<dt><code>NotLockerOwner(address claimedOwner, address actualOwner)</code></dt>
<dd>Thrown when attempted to make a call that only the owner of this contract's owner can make.</dd>
</dl>

### Mare Bits Vault
#### Functions
<dl>
<dt><code>bestPony() returns (string)</code></dt>
<dd>Returns the best pony.</dd>

<dt><code>onERC1155BatchReceived(address operator, address from, uint256[] ids, uint256[] values, bytes data) returns (bytes4)</code></dt>
<dd>Handles the receipt of multiple ERC-1155 token types.  This function is called at the end of a <code>safeBatchTransferFrom</code> after the balances have been updated.  It returns its Solidity selector to confirm the token transfers.</dd>

<dt><code>onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes data) returns (bytes4)</code></dt>
<dd>Handles the receipt of a single ERC-1155 token type.  This function is called at the end of a <code>safeTransferFrom</code> after the balance has been updated.  It returns its Solidity selector to confirm the token transfer.</dd>

<dt><code>onERC721Received(address operator, address from, uint256 tokenId, bytes data) returns (bytes4)</code></dt>
<dd>Whenever an ERC-721 <code>tokenId</code> is transferred to this contract via <code>safeTransferFrom</code> by <code>operator</code> from <code>from</code>, this function is called.  It returns its Solidity selector to confirm the token transfer.</dd>

<dt><code>supportsInterface(bytes4 interfaceId) returns (bool)</code></dt>
<dd>See <a href="https://eips.ethereum.org/EIPS/eip-165#how-a-contract-will-publish-the-interfaces-it-implements">ERC-165</a>.</dd>
</dl>