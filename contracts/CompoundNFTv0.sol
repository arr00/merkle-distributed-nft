// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.11;

import "./MerkleDistributedNFT.sol";
import "./interfaces/ITimelock.sol";

contract CompoundNFTv0 is MerkleDistributedNFT {
	bool public active;
	uint256 public activationTime;

	constructor(string memory name_, string memory symbol_, bytes32 merkleRoot_) MerkleDistributedNFT(name_, symbol_, merkleRoot_) public {}


	function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external override {
		require(active, "CompoundNFTv0::claim: not yet active");
		require(block.timestamp < activationTime + 3 days, "CompoundNFTv0::claim: claiming period is over");
		require(msg.sender == account, "CompoundNFTv0::claim: only recipient can claim");

		// Pass checks, allow claim
		_claim(index, account, amount, merkleProof);
	}


	function activate() external {
		require(ITimelock(0x6d903f6003cca6255D85CcA4D3B5E5146dC33925).admin() == 0xc0Da02939E1441F497fd74F78cE7Decb17B66529, "CompoundNFTv0::activate: bravo not yet active");
		require(!active, "CompoundNFTv0::activate: already activated");

		active = true;
		activationTime = block.timestamp;
	}

	function tokenURI(uint256) public view override returns (string memory) {
        return "ipfs://QmYoaQSKLvRcKyRtyWT73N8c5xTt9P1Brjbn47q2puLAjt";
    }
}