// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WLDHUBItems} from "../src/WLDHubItems.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract MockERC1155Receiver is IERC1155Receiver {
    function onERC1155Received(address, address, uint256, uint256, bytes calldata)
        external
        pure
        override
        returns (bytes4)
    {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        pure
        override
        returns (bytes4)
    {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }
}

contract WLDHUBItemsTest is Test {
    WLDHUBItems public token;
    MockERC1155Receiver public receiver;
    address public owner;
    address public user1;
    address public user2;

    // Events to test
    event TokenMinted(address indexed to, uint256 indexed id, uint256 amount);
    event TokenBatchMinted(address indexed to, uint256[] ids, uint256[] amounts);

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);

        token = new WLDHUBItems(owner);
        receiver = new MockERC1155Receiver();
    }

    function testConstructor() public {
        assertEq(token.owner(), owner);
        assertFalse(token.paused());
    }

    function testSetURI() public {
        uint256 tokenId = 1;
        string memory newURI = "https://example.com/token/1";

        token.setURI(tokenId, newURI);
        assertEq(token.uri(tokenId), newURI);
    }

    function testSetURIOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        token.setURI(1, "https://example.com/token/1");
    }

    function testMint() public {
        uint256 tokenId = 1;
        uint256 amount = 100;

        vm.expectEmit(true, true, true, true);
        emit TokenMinted(user1, tokenId, amount);

        token.mint(user1, tokenId, amount, "");

        assertEq(token.balanceOf(user1, tokenId), amount);
        assertEq(token.totalSupply(tokenId), amount);
        assertTrue(token.exists(tokenId));
    }

    function testMintToZeroAddress() public {
        vm.expectRevert(WLDHUBItems.InvalidAddress.selector);
        token.mint(address(0), 1, 100, "");
    }

    function testMintOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        token.mint(user2, 1, 100, "");
    }

    function testMintBatch() public {
        uint256[] memory ids = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);

        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;

        vm.expectEmit(true, true, true, true);
        emit TokenBatchMinted(user1, ids, amounts);

        token.mintBatch(user1, ids, amounts, "");

        uint256[] memory balances = token.balanceOfBatch(_buildAddressArray(user1, 3), ids);

        assertEq(balances[0], amounts[0]);
        assertEq(balances[1], amounts[1]);
        assertEq(balances[2], amounts[2]);

        assertEq(token.totalSupply(1), 100);
        assertEq(token.totalSupply(2), 200);
        assertEq(token.totalSupply(3), 300);
    }

    function testMintBatchToZeroAddress() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        ids[0] = 1;
        amounts[0] = 100;

        vm.expectRevert(WLDHUBItems.InvalidAddress.selector);
        token.mintBatch(address(0), ids, amounts, "");
    }

    function testMintBatchArrayLengthMismatch() public {
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](1);
        ids[0] = 1;
        ids[1] = 2;
        amounts[0] = 100;

        vm.expectRevert(WLDHUBItems.InvalidArrayLength.selector);
        token.mintBatch(user1, ids, amounts, "");
    }

    function testMintBatchOnlyOwner() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        ids[0] = 1;
        amounts[0] = 100;

        vm.prank(user1);
        vm.expectRevert();
        token.mintBatch(user2, ids, amounts, "");
    }

    function testPause() public {
        token.pause();
        assertTrue(token.paused());
    }

    function testPauseOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        token.pause();
    }

    function testUnpause() public {
        token.pause();
        assertTrue(token.paused());

        token.unpause();
        assertFalse(token.paused());
    }

    function testUnpauseOnlyOwner() public {
        token.pause();

        vm.prank(user1);
        vm.expectRevert();
        token.unpause();
    }

    function testTransferWhenPaused() public {
        // First mint some tokens
        token.mint(user1, 1, 100, "");

        // Pause the contract
        token.pause();

        // Try to transfer - should fail
        vm.prank(user1);
        vm.expectRevert();
        token.safeTransferFrom(user1, user2, 1, 50, "");
    }

    function testBurn() public {
        uint256 tokenId = 1;
        uint256 mintAmount = 100;
        uint256 burnAmount = 30;

        // Mint tokens first
        token.mint(user1, tokenId, mintAmount, "");

        // Burn tokens
        vm.prank(user1);
        token.burn(user1, tokenId, burnAmount);

        assertEq(token.balanceOf(user1, tokenId), mintAmount - burnAmount);
        assertEq(token.totalSupply(tokenId), mintAmount - burnAmount);
    }

    function testBurnBatch() public {
        uint256[] memory ids = new uint256[](2);
        uint256[] memory mintAmounts = new uint256[](2);
        uint256[] memory burnAmounts = new uint256[](2);

        ids[0] = 1;
        ids[1] = 2;
        mintAmounts[0] = 100;
        mintAmounts[1] = 200;
        burnAmounts[0] = 30;
        burnAmounts[1] = 50;

        // Mint tokens first
        token.mintBatch(user1, ids, mintAmounts, "");

        // Burn tokens
        vm.prank(user1);
        token.burnBatch(user1, ids, burnAmounts);

        assertEq(token.balanceOf(user1, 1), 70);
        assertEq(token.balanceOf(user1, 2), 150);
        assertEq(token.totalSupply(1), 70);
        assertEq(token.totalSupply(2), 150);
    }

    function testSupportsInterface() public {
        // Test ERC1155 interface
        assertTrue(token.supportsInterface(0xd9b67a26));
        // Test ERC165 interface
        assertTrue(token.supportsInterface(0x01ffc9a7));
    }

    function testSafeTransferFrom() public {
        uint256 tokenId = 1;
        uint256 amount = 100;
        uint256 transferAmount = 30;

        // Mint tokens
        token.mint(user1, tokenId, amount, "");

        // Transfer tokens
        vm.prank(user1);
        token.safeTransferFrom(user1, user2, tokenId, transferAmount, "");

        assertEq(token.balanceOf(user1, tokenId), amount - transferAmount);
        assertEq(token.balanceOf(user2, tokenId), transferAmount);
    }

    function testSafeBatchTransferFrom() public {
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        uint256[] memory transferAmounts = new uint256[](2);

        ids[0] = 1;
        ids[1] = 2;
        amounts[0] = 100;
        amounts[1] = 200;
        transferAmounts[0] = 30;
        transferAmounts[1] = 50;

        // Mint tokens
        token.mintBatch(user1, ids, amounts, "");

        // Transfer tokens
        vm.prank(user1);
        token.safeBatchTransferFrom(user1, user2, ids, transferAmounts, "");

        assertEq(token.balanceOf(user1, 1), 70);
        assertEq(token.balanceOf(user1, 2), 150);
        assertEq(token.balanceOf(user2, 1), 30);
        assertEq(token.balanceOf(user2, 2), 50);
    }

    function testSetApprovalForAll() public {
        vm.prank(user1);
        token.setApprovalForAll(user2, true);

        assertTrue(token.isApprovedForAll(user1, user2));

        vm.prank(user1);
        token.setApprovalForAll(user2, false);

        assertFalse(token.isApprovedForAll(user1, user2));
    }

    function testMintWithData() public {
        bytes memory data = "test data";
        token.mint(address(receiver), 1, 100, data);

        assertEq(token.balanceOf(address(receiver), 1), 100);
    }

    function testMintBatchWithData() public {
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        amounts[0] = 100;
        amounts[1] = 200;

        bytes memory data = "batch test data";
        token.mintBatch(address(receiver), ids, amounts, data);

        assertEq(token.balanceOf(address(receiver), 1), 100);
        assertEq(token.balanceOf(address(receiver), 2), 200);
    }

    // Helper function to build address array for balanceOfBatch
    function _buildAddressArray(address addr, uint256 length) internal pure returns (address[] memory) {
        address[] memory addresses = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            addresses[i] = addr;
        }
        return addresses;
    }

    // Fuzz testing
    function testFuzzMint(address to, uint256 id, uint256 amount) public {
        vm.assume(to != address(0));
        vm.assume(amount > 0 && amount < type(uint128).max);

        token.mint(to, id, amount, "");
        assertEq(token.balanceOf(to, id), amount);
    }

    function testFuzzSetURI(uint256 id, string memory newURI) public {
        token.setURI(id, newURI);
        assertEq(token.uri(id), newURI);
    }
}
