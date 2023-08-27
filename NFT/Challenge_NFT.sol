// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Challenge_NFT is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    string public uri;

    mapping(uint256 => address) public challenge;

    constructor(string memory _uri) ERC721("Web3 Guardians Challenge", "WGC") {
        // start with 1
        _tokenIdCounter.increment();
        uri = _uri;
    }

    function mint(address to) external returns (uint256 tokenId) {
        tokenId = _tokenIdCounter.current();

        require(challenge[tokenId] == msg.sender, "No active challenge");
        challenge[tokenId] = address(1);

        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        emit Solved(tokenId, to);
    }

    function addChallenge(address _challenge, uint256 _id) external onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        uint256 id = _id == 0 ? tokenId : _id;

        require(id >= tokenId, "Can't overwrite past challenges");
        require(_challenge != address(0), "Zero address");

        challenge[id] = _challenge;

        emit ChallengeAdded(id, _challenge);
    }

    function _baseURI() internal view override returns (string memory) {
        return uri;
    }

    function setUri(string memory _uri) external onlyOwner {
        if (keccak256(abi.encodePacked(uri)) == keccak256(abi.encodePacked(""))) {
            uri = _uri;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721)
    {
        require(from == address(0), "Token not transferable");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    event Solved(uint256 indexed id, address solver);
    event ChallengeAdded(uint256 indexed id, address newChallenge);
}
