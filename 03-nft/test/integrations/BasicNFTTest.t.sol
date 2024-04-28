// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployBasicNFT} from "../../script/DeployBasicNFT.s.sol";
import {BasicNFT} from "../../src/BasicNFT.sol";

contract BasicNFTTest is Test {
    DeployBasicNFT public deployer;
    BasicNFT public basicNft;
    address public USER = makeAddr("KENTO");

    // TOOD:自己尝试上传元数据到IPFS
    string public constant PUG = "ipfs://xxx";

    function setUp() public {
        deployer = new DeployBasicNFT();
        basicNft = deployer.run();
    }

    function testNameIsCorrect() public view {
        string memory exepectedName = "Dogie";
        string memory actualName = basicNft.name();

        assertEq(keccak256(abi.encodePacked(actualName)), keccak256(abi.encodePacked(exepectedName)));
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        basicNft.mintNft(PUG);

        assert(basicNft.balanceOf(USER) == 1);
        assert(keccak256(abi.encodePacked(PUG)) == keccak256(abi.encodePacked(basicNft.tokenURI(0))));
    }
}
