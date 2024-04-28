// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployMoodNFT is Script {
    function run() external returns (MoodNft) {
        string memory happySvg = vm.readFile("./img/happy.svg");
        string memory sadSvg = vm.readFile("./img/sad.svg");
        vm.startBroadcast();
        MoodNft nft = new MoodNft(svgToImageURI(happySvg), svgToImageURI(sadSvg));
        vm.stopBroadcast();
        return nft;
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseUrl = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseUrl, svgBase64Encoded));
    }
}
