// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {BasicNFT} from "../src/BasicNFT.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MoodNft} from "../src/MoodNft.sol";

contract MintBasicNft is Script {
    string private constant PUG = "ipfs://QmYx6GsYAKnNzZ9A6NvEKV9nf1VaDzJrqDR23Y8YSkebLU";

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("BasicNFT", block.chainid);
        mintNftOnContract(contractAddress);
    }

    function mintNftOnContract(address contractAddress) public {
        vm.startBroadcast();
        BasicNFT(contractAddress).mintNft(PUG);
        vm.stopBroadcast();
    }
}

contract MintMoodNft is Script {
    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("MoodNft", block.chainid);
        mintNftOnContract(contractAddress);
    }

    function mintNftOnContract(address _address) public {
        vm.startBroadcast();
        MoodNft(_address).safeMint();
        vm.stopBroadcast();
    }
}
