// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.11;

abstract contract ITimelock {
	function admin() public virtual returns (address);
}