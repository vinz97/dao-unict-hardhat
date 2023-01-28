// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NftUnict is ERC721 {
    mapping(uint256 => string) tokenUris;

    uint256 private s_tokenCounter;

    constructor() ERC721("NftUnict", "NFTUCT") {
        s_tokenCounter = 0;
    }

    function mintNft(string calldata nftUrl, address ownerNft) public {
        _safeMint(ownerNft, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
        tokenUris[s_tokenCounter] = nftUrl;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        // require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return tokenUris[tokenId];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
