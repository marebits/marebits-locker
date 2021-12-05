// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./Account.sol";
import "./Base64.sol";
import "./Bools.sol";
import "./MarebitsLockerTokenMetadataSVGBuilder.sol";
import "./Token.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title MarebitsLockerTokenMetadataBuilder library grouping functions related to composing the metadata for a Mare Bits Locker Token
 * @author Twifag
 */
library MarebitsLockerTokenMetadataBuilder {
	using Base64 for bytes;
	using Bools for bool;
	using Strings for uint256;
	using Token for Token.Type;

	/// @dev the constant selector for the symbol selector, `bytes4(keccak256("symbol()")`
	bytes4 constant SYMBOL_SELECTOR = 0x95d89b41;

	/**
	 * @dev Calls an external view token contract method that returns a symbol or name and parses the output into a string
	 * @param token address where function call will be attempted
	 * @param selector defining the keccak256 hash of the targeted method
	 * @return result string
	 */
	function _attemptStaticCall(address token, bytes4 selector) private view returns (string memory result) {
		(bool isSuccess, bytes memory data) = token.staticcall(abi.encodeWithSelector(selector));

		if (isSuccess) {
			if (data.length == 32) {
				result = _bytes32ToString(abi.decode(data, (bytes32)));
			} else if (data.length > 64) {
				result = abi.decode(data, (string));
			}
		}
	}

	function _bytes32ToString(bytes32 input) private pure returns (string memory output) {
		bytes memory bytesString = new bytes(32);
		uint8 charCount = 0;

		for (uint8 i = 0; i < 32; i++) {
			bytes1 char = input[i];

			if (char != 0) {
				bytesString[charCount++] = char;
			}
		}
		bytes memory bytesStringTrimmed = new bytes(charCount);

		for (uint8 i = 0; i < charCount; i++) {
			bytesStringTrimmed[i] = bytesString[i];
		}
		return string(bytesStringTrimmed);
	}

	/**
	 * @dev Escapes double-quote and backslash characters for inclusion in JSON strings
	 * @param word potentially containing characters to be escaped
	 * @return string escaped word
	 */
	function _escapeQuotes(string memory word) internal pure returns (string memory) {
		bytes memory wordBytes = bytes(word);
		uint8 quotesCount;

		for (uint8 i = 0; i < wordBytes.length; i++) {
			if (wordBytes[i] == '"' || wordBytes[i] == "\\") {
				quotesCount++;
			}
		}

		if (quotesCount > 0) {
			bytes memory escapedBytes = new bytes(wordBytes.length + quotesCount);
			uint8 i;

			for (uint8 j = 0; j < wordBytes.length; j++) {
				if (wordBytes[j] == '"' || wordBytes[j] == "\\") {
					escapedBytes[i++] = "\\";
				}
				escapedBytes[i++] = wordBytes[j];
			}
			return string(escapedBytes);
		}
		return word;
	}

	/**
	 * @param account containing the amount to return
	 * @return string the amount as a strong or, if the amount is 1, the word "a(n)"
	 */
	function _getAmount(Account.Info storage account) private view returns (string memory) {
		if (account.amount == 1) {
			return "a(n)";
		}
		return account.amount.toString();
	}

	/**
	 * @param account containing the information to return
	 * @return string the description line describing the deposited token ID for those accounts that contain ERC721 or ERC1155 tokens; otherwise, an empty string is returned
	 */
	function _getDepositedTokenId(Account.Info storage account) private view returns (string memory) {
		if (account.tokenType == Token.Type.ERC1155 || account.tokenType == Token.Type.ERC721) {
			return string(abi.encodePacked("* Deposited token ID: ", account.tokenId.toString(), "\\n"));
		}
		return "";
	}

	/**
	 * @param account containing the information to describe
	 * @param symbol of the token deposited into the account
	 * @param isSymbolDefault is true if the symbol was set to a default value; otherwise, it is true
	 * @return description string describing the account
	 */
	function _getDescription(Account.Info storage account, string memory symbol, bool isSymbolDefault) private view returns (string memory description) {
		symbol = _escapeQuotes(symbol);
		description = string(abi.encodePacked(
			"This non-fungible token represents a deposit of ", _getAmount(account), " ", symbol, " ", _pluralize("token", account.amount, "s"), 
			" in the Mare Bits Locker.  The holder of this token is entitled to withdraw their deposit anytime after block timestamp ", 
			uint256(account.unlockTime).toString(), " has passed.\\n\\n"
			"* ", (isSymbolDefault ? " Asset" : symbol), " address: ", uint256(uint160(account.tokenContract)).toString(), "\\n", 
			_getDepositedTokenId(account), 
			"* Deposited amount: ", account.amount.toString(), "\\n"
			"* This token ID: ", account.accountId.toString(), "\\n\\n"
			"See https://locker.mare.biz/ for more information."
		));
	}

	/**
	 * @param account from which to get the token symbol name
	 * @return symbol string describing the token deposited into the account
	 * @return isSymbolDefault bool is true if the symbol was set to a default value; otherwise, it is true
	 */
	function _getTokenSymbol(Account.Info storage account) private view returns (string memory symbol, bool isSymbolDefault) {
		symbol = _attemptStaticCall(account.tokenContract, SYMBOL_SELECTOR);
		isSymbolDefault = bytes(symbol).length == 0;

		if (isSymbolDefault) {
			symbol = _bytes32ToString(bytes32(account.tokenType.nameOf()));
		}
	}

	/**
	 * @param word to pluralize
	 * @param number the number of `word`(s)
	 * @param pluralEnding the ending to add to `word` to make it plural (usually "s" or "es" in English)
	 * @return the `word` pluralized as necessary
	 */
	function _pluralize(string memory word, uint256 number, string memory pluralEnding) private pure returns (string memory) { return (number == 1) ? word : string(abi.encodePacked(word, pluralEnding)); }

	/**
	 * @param account from which to get the image URI
	 * @param symbol of the token deposited into `account`
	 * @return image string the SVG image data: URI for account `account` in base64 format
	 */
	function getImage(Account.Info storage account, string memory symbol) public view returns (string memory image) {
		if (bytes(symbol).length == 0) {
			(symbol,) = _getTokenSymbol(account);
		}
		return MarebitsLockerTokenMetadataSVGBuilder.getImage(account, symbol);
	}

	/**
	 * @param account for which to get metadata
	 * @return string the JSON encoded metadata for account `account`
	 */
	function getMetadata(Account.Info storage account) public view returns (string memory) {
		(string memory symbol, bool isSymbolDefault) = _getTokenSymbol(account);
		return string(abi.encodePacked(
			'{'
				'"description":"', _getDescription(account, symbol, isSymbolDefault), '",'
				'"external_url":"https://mare.biz/",'
				'"image":"', MarebitsLockerTokenMetadataSVGBuilder.getImage(account, symbol), '",'
				'"name":"\\uD83D\\uDC0E\\u200D\\u2640\\uFE0F\\uD83D\\uDD12\\uD83E\\uDE99",'
				'"properties":{'
					'"accountId":"', account.accountId.toString(), '",'
					'"amount":"', account.amount.toString(), '",'
					'"isBurned":', account.isBurned.toBytes(), ','
					'"isRedeemed":', account.isRedeemed.toBytes(), ','
					'"tokenContract":"', uint256(uint160(account.tokenContract)).toString(), '",'
					'"tokenType":"', account.tokenType.nameOf(), '",'
					'"tokenId":"', account.tokenId, ','
					'"unlockTime":"', uint256(account.unlockTime).toString(), '"'
				'}'
			'}'
		));
	}

	/**
	 * @param account for which to get the metadata URI
	 * @return string the metadata data: URI for account `account` in base64 format
	 */
	function getMetadataUri(Account.Info storage account) public view returns (string memory) { return string(abi.encodePacked("data:application/json;base64,", bytes(getMetadata(account)).encode())); }
}