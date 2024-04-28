// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    error MoodNft__CantFlipMoodIfNotOwner(address sender, address approved, address owner);

    event CreatedNFT(uint256 indexed tokenId);

    uint256 private _nextTokenId;
    string private s_happySvgImageUri;
    string private s_sadSvgImageUri;

    enum Mood {
        HAPPY,
        SAD
    }

    mapping(uint256 => Mood) s_tokenIdToMood;

    constructor(string memory happyUri, string memory sadUri) ERC721("MoodNft", "MN") {
        _nextTokenId = 0;
        s_happySvgImageUri = happyUri;
        s_sadSvgImageUri = sadUri;
    }

    function safeMint() public {
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        s_tokenIdToMood[tokenId] = Mood.HAPPY;
        emit CreatedNFT(tokenId);
    }

    function flipMood(uint256 tokenId) public {
        if (getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender) {
            revert MoodNft__CantFlipMoodIfNotOwner(msg.sender, getApproved(tokenId), ownerOf(tokenId));
        }

        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageUri;
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            imageUri = s_happySvgImageUri;
        } else {
            imageUri = s_sadSvgImageUri;
        }

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes( // bytes casting actually unnecessary as 'abi.encodePacked()' returns a bytes
                        abi.encodePacked(
                            '{"name":"',
                            name(), // You can add whatever name here
                            '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                            '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                            imageUri,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function getTokenIdMood(uint256 tokenId) public view returns (uint256 mood) {
        if (getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender) {
            revert MoodNft__CantFlipMoodIfNotOwner(msg.sender, getApproved(tokenId), ownerOf(tokenId));
        }
        return uint256(s_tokenIdToMood[tokenId]);
    }
}
