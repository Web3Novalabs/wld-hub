// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {QuickNodeNFT} from "../src/ERC721.sol";

contract QuickNodeNFTTest is Test {
    QuickNodeNFT public nft;
    address public owner;
    address public user;
    string public constant TOKEN_URI = "ipfs://bafkreigq4li5emwa77ibch6ysqz5nfanx3lhpku4uv2xgq7sfsek5s7eya";

    function setUp() public {
        owner = makeAddr("owner");
        user = makeAddr("user");
        vm.startPrank(owner);
        nft = new QuickNodeNFT();
        vm.stopPrank();
    }

    function test_Constructor() public view {
        assertEq(nft.name(), "QuickNode Sharks");
        assertEq(nft.symbol(), "QNS");
        assertEq(nft.owner(), owner);
    }

    function test_Mint() public {
        uint256 tokenId = 1;
        vm.startPrank(owner);
        nft.mint(user, tokenId, TOKEN_URI);
        vm.stopPrank();

        assertEq(nft.ownerOf(tokenId), user);
        assertEq(nft.tokenURI(tokenId), TOKEN_URI);
    }

    function test_RevertWhen_MintNotOwner() public {
        uint256 tokenId = 1;
        vm.startPrank(user);
        vm.expectRevert();
        nft.mint(user, tokenId, TOKEN_URI);
        vm.stopPrank();
    }

    function test_RevertWhen_MintDuplicateTokenId() public {
        uint256 tokenId = 1;
        vm.startPrank(owner);
        nft.mint(user, tokenId, TOKEN_URI);
        vm.expectRevert();
        nft.mint(user, tokenId, TOKEN_URI);
        vm.stopPrank();
    }

    function test_RevertWhen_MintToZeroAddress() public {
        uint256 tokenId = 1;
        vm.startPrank(owner);
        vm.expectRevert();
        nft.mint(address(0), tokenId, TOKEN_URI);
        vm.stopPrank();
    }
}
