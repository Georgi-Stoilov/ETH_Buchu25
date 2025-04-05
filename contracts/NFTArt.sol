// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTArt is ERC721, Ownable {
    uint256 public nextTokenId;
    // Designated oracle address for updating metadata
    address public oracle;

    // Mapping tokenId => tokenURI
    mapping(uint256 => string) private _tokenURIs;

    event Minted(uint256 tokenId, address owner);
    event MetadataUpdated(uint256 tokenId, string newTokenURI);

    constructor(address _oracle) ERC721("NFTArt", "NFTA") {
        oracle = _oracle;
    }

    function mint(address to, string memory tokenURI_) external onlyOwner returns (uint256) {
        uint256 tokenId = nextTokenId;
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI_);
        nextTokenId++;
        emit Minted(tokenId, to);
        return tokenId;
    }

    function listToken(uint256 tokenId, uint256 price) external {
        // ... Add listing functionality
    }

    function updateTokenURI(uint256 tokenId, string memory newTokenURI) external {
        require(msg.sender == oracle, "Only designated oracle can update metadata");
        require(_exists(tokenId), "Nonexistent token");
        _setTokenURI(tokenId, newTokenURI);
        emit MetadataUpdated(tokenId, newTokenURI);
    }

    function _setTokenURI(uint256 tokenId, string memory tokenURI_) internal {
        _tokenURIs[tokenId] = tokenURI_;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }
}