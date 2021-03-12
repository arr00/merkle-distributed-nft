// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/cryptography/MerkleProof.sol";
import "./interfaces/IMerkleDistributedNFT.sol";


contract MerkleDistributedNFT is ERC721, IMerkleDistributedNFT {
    bytes32 public immutable override merkleRoot;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(string memory name_, string memory symbol_, bytes32 merkleRoot_) ERC721(name_, symbol_) public {
        merkleRoot = merkleRoot_;

        // Remember to ser URI stuff
    }

    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) virtual external override {
        _claim(index, account, amount, merkleProof);
    }

    function _claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) internal {
        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

        // Mark it claimed and send the token.
        _setClaimed(index);
        
        // Mint NFT to user in order of claim
        _safeMint(account, totalSupply() + 1);

        emit Claimed(index, account, amount);
    }
}
