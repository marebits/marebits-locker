// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

import "./Account.sol";
import "./Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title MarebitsLockerTokenMetadataSVGBuilder library grouping functions related to composing the SVG image metadata for a Mare Bits Locker Token
 * @author Twifag
 */
library MarebitsLockerTokenMetadataSVGBuilder {
	using Base64 for bytes;
	using Strings for uint256;

	/**
	 * @dev Escapes less than (<) and backslash characters for inclusion in XML strings
	 * @param word potentially containing characters to be escaped
	 * @return string escaped word
	 */
	function _escapeQuotes(string memory word) internal pure returns (string memory) {
		bytes memory wordBytes = bytes(word);
		uint8 ltCount;
		uint8 slashCount;

		for (uint8 i = 0; i < wordBytes.length; i++) {
			if (wordBytes[i] == "<") {
				ltCount ++;
			} else if (wordBytes[i] == "\\") {
				slashCount++;
			}
		}

		if (ltCount + slashCount > 0) {
			bytes memory escapedBytes = new bytes(wordBytes.length + 3 * ltCount + slashCount);
			uint8 i;

			for (uint8 j = 0; j < wordBytes.length; j++) {
				if (wordBytes[j] == "<") {
					escapedBytes[i++] = "&";
					escapedBytes[i++] = "l";
					escapedBytes[i++] = "t";
					escapedBytes[i++] = ";";
				} else {
					if (wordBytes[j] == "\\") {
						escapedBytes[i++] = "\\";
					}
					escapedBytes[i++] = wordBytes[j];
				}
			}
			return string(escapedBytes);
		}
		return word;
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
		return string(abi.encodePacked("data:image/svg+xml;base64,", abi.encodePacked(
			'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve" viewBox="0 0 700 700">'
				'<style>'
					'*{overflow:visible}.st0{fill:#a5a3ff}.st2{fill:#827eea}text{fill:#eaeef0;font-family:monospace;font-size:24px}text.smaller{font-size:18px}'
				'</style>'
				'<rect width="100%" height="100%" fill="#1a0c27"/>'
				'<g style="transform:translateY(80%) translateX(7.5%)">'
					'<rect width="85%" height="120" y="-12" fill="rgba(255,255,255,0.2)" rx="8" ry="8"/>'
					'<text x="10" y="10">ID: ', account.accountId.toString(), '</text>'
					'<text x="10" y="40">Locked asset: ', account.amount.toString(), ' ', symbol, ' ', _pluralize("token", account.amount, "s"), '</text>'
					'<text x="10" y="65" class="smaller">Unlock time: ', uint256(account.unlockTime).toString(), ' (seconds after 1970-01-01)</text>'
					'<text x="10" y="90" class="smaller">Asset contract: ', uint256(uint160(account.tokenContract)).toString(), '</text>'
				'</g>'
				'<g style="transform:scale(.75) translateX(120px)">'
					'<defs>'
						'<filter id="moon-glow" width="200%" height="200%" x="-50%" y="-50%">'
							'<feGaussianBlur in="SourceGraphic" stdDeviation="50"/>'
						'</filter>'
					'</defs>'
					'<circle cx="50%" cy="50%" r="48%" fill="#3e3efd" filter="url(#moon-glow)" transform="matrix(.95 0 0 .95 20 20)"/>'
					'<path d="M16 370a334 334 0 0 1 602-217A333 333 0 1 1 16 370zm334-227c18-31-56-53-63-19-1 2-4-1-6-1-9-4-20 5-18 14 1 10 14 14 21 9 3-1 5-7 8-5 13 16 38 14 55 5-10 13-3 32 10 40 3 2-5 5-6 7-24 26-30 74-5 101-8 0-16-1-21 6-7 6-13-10-28-3-19 10-18 39-6 53 9 15 31 5 32-10 1-4 1-4 4-2 27 16 43-13 33-36 30 6 46-28 53-52 6 9 10 12 20 11-7 11 2 30 16 24 18-12 5-24-11-26 23-11 18-44 24-30 3 9 12 14 17 21-13-3-18 13-12 23s20 15 31 10c9-5 5-18 5-27-1-6 8-1 11-5 1-1 3-7 5-5 6 7 9 16 13 24 3 3-9 1-11 9-4 21-4 6-29 12-35 8-29 48-13 72-22-9-33 16-24 34 14 27 44 4 38-20-1-5 15 7 24-4 0 9 1 18 6 27 1 1 1 1-1 2-15 0-29 8-35 22-1 3-3-3-5-3-12-11-33-9-42 4-11 16-11 38-5 56 4 21 23 21 13 44-1 2-8-4-10-4-1-1-2-1-1-2 2-8 2-17-2-24-10-17-33 2-29 18-1 4 5 13-1 15-12 2-12 20-16 18-5-3-10-5-15-5-54 4-44 100 10 56 10-7 5-15 15-8 28 16 55-14 54-42 27 16 62 1 57-37-1-14-9-21-17-30 3-8 2-12 9-3 27 26 66 12 63-28 0-2 0-2 2-2 17-6 20-30 25-45 6-19 4-65-26-43-4 3 2-9-1-13 1-4 9 3 14-12 7 7 12 17 23 14s19-16 16-27c-2-14-18-28-32-20-3 1-3-4-4-5-2-7-6-13-13-17-5-3 8-7 8-23 1-22-15-53-41-50-3 0-7 2-9-1-3-13-5-28-20-31 17-12 17-42 0-54-21-16-42 6-34 28-5-3-10-6-15-7l-1-2c-1-5 3-7 5-11 3-9-3-19-10-25-3-3 2-5 4-6 15-8 0-29-14-27-9 1-23 6-23 17 0 2 3 5 0 6-14-1-29 4-38 15-12 13 1 31-3 31-9-3-19-1-28 4zm89 167c-3-39-49-16-58 7-12 19 9 45 30 35 16-7 26-25 28-42zm137-122c2-20-21-59-44-44-25 23 41 100 44 44zM130 554c68-2 21-100-29-88-52 13-14 92 29 88zm121-374c0 29 46 45 48 10 1-30-46-34-48-10zm67-24c-24 1-19 41-2 48 29 10 36-47 2-48zM77 345c2-19-17-40-36-30-34 21 35 81 36 30zm217-106c4 43 40 21 29-11-9-27-30-10-29 11zm62 105c-17-1-34 20-24 35 20 18 54-30 24-35zm-48 82c31-4 32-53-4-44-32 9-26 38 4 44zm213 100c7 38 56-31 18-23-10 4-17 13-18 23zM349 63c11-1 24-2 34-8 17-12 7-22-10-23-27-3 48 16-23 23-12 1-25 0-38-1-2-1-3 1 0 3 11 5 24 5 37 6zm258 196c-2-32-28-19-22 7 5 25 23 11 22-7zm-294 10c-9-1-23 6-18 16 19 22 54-13 18-16zM498 96c-2-12-19-14-28-8-16 17 26 29 28 8zm-248 83c-1-21-37-12-26 6 6 10 26 7 26-6zm-75 5c22 1 16-29-3-24-14 4-7 24 3 24zm305 386c1-8-8-19-13-9-3 6-18 10-8 17 8 6 22 3 21-8zM206 185c8 0 13-13 4-17-16-9-26 17-4 17zm80 181c-20 1-6 27 2 16 5-5 9-16-2-16zM148 175c9 0 14-9 5-13-5-4-18-2-15 6 2 4 6 7 10 7z" class="st0"/>'
					'<path d="M473 148c-8-22 13-44 34-28 17 12 17 42 0 54 15 3 17 18 20 31 2 3 6 1 9 1 26-3 42 28 41 50 1 14-13 22-8 23 7 4 11 10 13 17 1 1 1 7 4 5 14-8 30 6 32 20 3 11-5 24-16 27s-16-7-23-14c-4 15-13 8-14 12 3 4-4 16 1 13 30-22 32 24 26 43-5 15-8 39-25 45-2 0-2 0-2 2 3 40-36 54-63 28-7-9-6-5-9 3 8 9 16 16 17 30 5 38-30 53-57 37 1 28-26 58-54 42-10-7-5 1-14 8-55 44-65-52-11-56 5 0 10 2 15 5 3 3 4-17 16-18 6-2 0-11 1-15-4-16 19-35 29-18 4 7 4 16 2 24-1 1 0 2 1 2 2 0 10 6 10 4 10-23-8-22-13-44-6-18-6-40 5-56 9-13 30-15 42-4 2 0 4 6 6 3 5-14 19-22 34-22 2 0 2-1 1-2-4-8-6-18-6-27-9 12-25-1-24 4 6 24-24 47-38 20-9-18 2-43 24-34-15-23-22-64 13-72 26-6 25 9 29-11 2-9 14-7 12-10-5-8-8-17-14-24-2-2-4 4-5 5-3 4-12-1-11 5 0 9 4 22-5 27-11 5-25 0-31-10s-1-26 12-23c-5-7-14-12-17-21-6-14 0 19-24 30 16 2 29 15 11 26-14 6-23-13-16-24-10 1-14-2-20-11-7 24-23 58-53 52 10 23-6 52-33 36-3-2-3-2-3 2-2 16-24 25-33 10-12-14-12-43 6-53 15-7 21 9 28 3 5-7 13-6 21-6-25-27-19-75 5-101 1-2 9-5 6-7-13-8-20-27-10-40-17 9-42 11-55-5-3-2-5 4-8 5-7 5-20 1-21-9-1-9 9-17 18-14 2 0 5 4 6 1 7-34 81-12 63 19 9-5 19-7 28-4 4 0-8-18 3-31 9-11 24-16 39-15 2-1-1-4-1-6 0-11 14-16 23-16 14-3 29 19 14 26-2 1-7 4-4 6 7 6 14 16 10 25-2 4-6 6-5 11l1 2c5 1 10 4 15 7zm-67 74c2-29-37-37-53-17a58 58 0 0 0-7 69c12 19 37 14 46-5 9-14 13-31 14-47zm-94-84c9 0 30-4 21-17-23-26-61 11-21 17zm106 75c3-1 19-7 17-11-4-6-7-11-9-17h-1c-17 20-15 2-7 28zm-13-52-16-10c0 9-1 19-5 28l1 2c2 0 7 3 7 0-1-9 4-18 13-20zm75 0c0 15-2 12 13 11l-13-11z" class="st2"/>'
					'<path d="M439 310c-1 33-45 67-61 24-7-30 56-71 61-24zm137-122c-3 56-69-21-44-44 23-15 46 23 44 44zM130 554c-43 4-81-75-29-88 50-12 97 86 29 88zm0-6c50-3 14-78-22-73-48 8-14 74 22 73zm121-368c2-24 49-20 48 10-2 35-48 19-48-10z" class="st2"/>'
					'<path d="M318 156c34 1 27 58-2 48-17-7-22-47 2-48zM77 345c-1 51-69-9-36-30 19-10 38 11 36 30zm-30-20c-16 5 0 31 13 31 18 1-3-33-13-31zm247-86c-1-21 20-38 29-11 11 32-25 54-29 11zm62 105c30 5-4 53-24 35-10-15 7-36 24-35zm-48 82c-30-6-35-35-4-44 36-9 35 40 4 44zm-5-10c15 0 23-24 7-29-22-4-32 26-7 29zm218 110c1-10 8-19 18-23 38-8-11 61-18 23zM349 63c-13-1-26-1-37-6-3-2-3-4 0-3 13 1 26 2 38 1 71-7-4-26 23-23 17 1 27 11 10 23-10 6-23 7-34 8zm258 196c1 18-17 32-22 7-6-26 20-39 22-7z" class="st2"/>'
					'<path d="M313 269c36 3 0 38-18 16-5-10 9-17 18-16zM498 96c-2 21-44 9-28-8 9-6 26-4 28 8zm-248 83c0 13-20 16-26 6-11-18 25-27 26-6zm-75 5c-10 0-17-20-3-24 19-5 25 25 3 24zm305 386c1 11-14 14-21 8-10-7 5-11 8-17 5-10 14 1 13 9z" class="st2"/>'
					'<path d="M206 185c-22 0-12-26 4-17 9 4 4 17-4 17zm80 181c11 0 7 11 2 16-8 11-22-15-2-16zM148 175c-4 0-8-3-10-7-3-8 10-10 15-6 9 4 4 13-5 13z" class="st2"/>'
					'<path d="M406 222c-1 16-5 33-14 47-9 19-34 24-46 5a58 58 0 0 1 7-70c16-19 55-11 53 18zm-94-84c-40-6-2-43 21-17 9 13-12 17-21 17zm106 75c-8-26-10-9 7-28h1c2 6 5 11 9 17 2 4-14 10-17 11zm-13-52c-9 2-14 11-13 20 0 3-5 0-7 0l-1-2c4-9 5-19 5-28l16 10zm75 0 13 11c-15 1-13 4-13-11zm-130-18zM130 548c-31 0-64-47-35-69 39-26 91 65 35 69zM47 325c10-2 31 32 13 31-12 0-28-26-13-31zm256 91c-25-3-15-33 7-29 16 5 8 29-7 29z" class="st0"/>'
					'<defs>'
						'<path id="a" d="M344 3C140 4-53 220 63 563c14 40-24 99 14 123 31 19 120-29 80-91-183-281 7-489 197-492 178-4 372 199 191 492-27 43 8 93 64 94 65 2 11-78 35-148C747 246 564 9 354 3h-10zm10 247c-37 0-76 50-32 113 0 66-42 97-43 163-3 143 144 149 145 5 0-75-41-98-46-166 46-64 15-116-24-115zm-20 173c6 0 12 2 18 7 23-18 50 1 39 39-7 26-37 59-36 101 15-28 52 2-3 40-46-25-34-72-2-40-1-41-23-60-35-93-13-32 1-54 19-54z"/>'
					'</defs>'
					'<path fill="#879599" fill-rule="evenodd" d="M343 10C139 12-54 227 62 570c14 40-24 99 14 123 31 20 121-29 80-91-183-280 8-488 197-492 178-3 372 199 191 492-27 44 8 93 64 95 65 1 11-79 35-148C746 253 563 16 353 10h-10zm10 247c-37 0-76 51-32 113 0 67-42 97-43 164-3 142 145 148 145 4 0-75-41-98-46-166 46-64 15-115-24-115zm-20 173c6 0 12 2 18 8 23-18 50 0 39 39-7 26-37 58-36 100 15-27 52 3-3 40-46-25-34-71-2-40 0-40-22-59-35-93-13-32 2-54 19-54zM134 621c5 0 10 4 10 10 0 5-5 10-10 10s-10-5-10-10c0-6 4-10 10-10zm432 0c5 0 10 4 10 10s-5 10-10 10-10-5-10-10 4-10 10-10z" clip-rule="evenodd"/>'
					'<path fill="#abb5b7" fill-rule="evenodd" d="M343 2C139 4-54 219 62 562c14 40-24 99 14 123 31 20 121-29 80-91-183-280 8-488 197-492 178-3 372 199 191 492-27 44 8 93 64 95 65 1 11-79 35-148C746 245 563 8 353 2h-10zM134 613c6 0 10 4 10 10s-4 10-10 10c-5 0-10-5-10-10 0-6 4-10 10-10zm432 0c5 0 10 4 10 10s-5 10-10 10-10-5-10-10 4-10 10-10zM353 249c-37 0-76 51-32 113 0 67-42 97-43 164-3 142 145 148 145 4 0-75-41-98-46-166 46-64 15-115-24-115zm-20 173c6 0 12 2 18 8 23-18 50 0 39 39-7 26-37 58-36 100 15-27 52 3-3 40-46-25-34-71-2-40 0-40-22-59-35-93-13-32 2-54 19-54z" clip-rule="evenodd"/>'
					'<path fill="#ecedef" fill-rule="evenodd" d="M129 413c9 74 127 73 123 34-6-47-92 17-123-34z" clip-rule="evenodd"/>'
					'<path fill="#efaece" fill-rule="evenodd" d="M151 264c-54 60-29 113 2 132 44 26 91 3 114 23-26-75-116-37-116-155z" clip-rule="evenodd"/>'
					'<path fill="#f4b665" fill-rule="evenodd" d="M261 145c-33 72-24 108-1 151 42 77 24 117 0 83-25-38-63-47-79-101-14-48 16-103 80-133z" clip-rule="evenodd"/>'
					'<path fill="#d198e7" fill-rule="evenodd" d="M573 411c-10 75-128 74-123 35 5-47 91 17 123-35z" clip-rule="evenodd"/>'
					'<path fill="#a2ddf5" fill-rule="evenodd" d="M551 263c54 60 28 113-2 131-44 27-91 3-115 23 27-75 116-36 117-154z" clip-rule="evenodd"/>'
					'<path fill="#faf8b0" fill-rule="evenodd" d="M440 143c33 73 25 108 1 152-41 76-23 117 0 82 26-38 64-47 79-100 14-48-16-103-80-134z" clip-rule="evenodd"/>'
					'<g transform="translate(-1 -1)">'
						'<clipPath id="b">'
							'<use xlink:href="#a"/>'
						'</clipPath>'
						'<path fill="#fff" fill-opacity=".3" fill-rule="evenodd" d="m-73 256 51-79 766 387-47 34-770-342z" clip-path="url(#b)" clip-rule="evenodd"/>'
					'</g>'
					'<g transform="translate(-1 -1)">'
						'<defs>'
							'<use xlink:href="#a" id="c"/>'
						'</defs>'
						'<clipPath id="d">'
							'<use xlink:href="#c"/>'
						'</clipPath>'
						'<path fill="#fff" fill-opacity=".3" fill-rule="evenodd" d="m13 185 5-15 772 385v14L13 185z" clip-path="url(#d)" clip-rule="evenodd"/>'
					'</g>'
					'<path fill="#829093" fill-rule="evenodd" d="m352 273 5 32 22-8-18 20h2l12 19-4-4-14-5 1 3-7 35-5-35 2-3-15 5-4 4 11-19h3l-11-17-5-3 18 7 7-31z" clip-rule="evenodd"/>'
					'<path fill="#c3c3c3" fill-rule="evenodd" d="m374 300 5-3-16 20h-2l10 15 4 4-17-6-2-3h-9l-1 3-17 6 4-4 10-15h-3l-13-20 4 3 17 11 8-4 18-7z" clip-rule="evenodd"/>'
					'<path fill="#df3b7c" fill-rule="evenodd" d="m332 300 15 7 5-28 4 28 18-7-13 17 10 15-14-5-5 30-4-30-14 5 9-15-11-17z" clip-rule="evenodd"/>'
					'<g transform="translate(-1 -1)">'
						'<defs>'
							'<path id="e" d="m324 294 20 9 8-35 6 35 25-9-18 23 13 22-19-8-7 41-6-40-20 7 13-22z"/>'
						'</defs>'
						'<defs>'
							'<path id="g" d="M365 317h-3l4 12 7 5 5 5-4-22z"/>'
						'</defs>'
						'<clipPath id="f">'
							'<use xlink:href="#e"/>'
						'</clipPath>'
						'<clipPath id="h" clip-path="url(#f)">'
							'<use xlink:href="#g"/>'
						'</clipPath>'
						'<path fill="#e5578f" fill-rule="evenodd" d="m357 329 2 2 18 9 1-1-5-4-13-8-3 2z" clip-path="url(#h)" clip-rule="evenodd"/>'
					'</g>'
				'</g>'
			'</svg>'
		).encode()));
	}
}