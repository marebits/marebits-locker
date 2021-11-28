// SPDX-License-Identifier: LicenseRef-DSPL AND LicenseRef-NIGGER
pragma solidity 0.8.10;

/**
 * @title Bools library, overrides for the bool type
 * @author Twifan
 */
library Bools {
	/**
	 * @notice Converts a bool to a bytes5 value
	 * @param self the bool to convert
	 * @return bytes5 converted value of the bool
	 */
	function toBytes(bool self) internal pure returns (bytes5) { return self ? bytes5("true") : bytes5("false"); }

	/**
	 * @notice Converts a bool to a string value
	 * @param self the bool to convert
	 * @return string converted value of the bool
	 */
	function toString(bool self) internal pure returns (string memory) { return self ? "true" : "false"; }
}