// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TimeLockedVault.sol";

contract MockERC20 is IERC20 {
    string public name = "Mock Token";
    string public symbol = "MTKN";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 amount) external {
        balances[to] += amount;
        totalSupply += amount;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(balances[sender] >= amount, "Insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "Insufficient allowance");
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowance[sender][msg.sender] -= amount;
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}

contract TimeLockedVaultTest is Test {
    TimeLockedVault vault;
    MockERC20 token;
    address user = address(0xBEEF);
    uint256 initialBalance = 1000 ether;

    function setUp() public {
        token = new MockERC20();
        vault = new TimeLockedVault(address(token));
        token.mint(user, initialBalance);
        vm.prank(user);
        token.approve(address(vault), initialBalance);
    }

    function testLockTokensSuccess() public {
        vm.prank(user);
        vault.lockTokens(100 ether, 1 days);

        TimeLockedVault.Lock[] memory locks = vault.getLocks(user);
        assertEq(locks.length, 1);
        assertEq(locks[0].amount, 100 ether);
    }

    function testWithdrawFailsIfStillLocked() public {
        vm.prank(user);
        vault.lockTokens(100 ether, 1 days);

        vm.prank(user);
        vm.expectRevert("Tokens are still locked");
        vault.withdrawTokens(0);
    }

    function testWithdrawSucceedsAfterUnlock() public {
        vm.prank(user);
        vault.lockTokens(100 ether, 1 days);

        // Fast forward time
        vm.warp(block.timestamp + 2 days);

        vm.prank(user);
        vault.withdrawTokens(0);

        assertEq(token.balanceOf(user), initialBalance);
    }

    function testLockFailsIfAmountZero() public {
        vm.prank(user);
        vm.expectRevert("Amount must be greater than zero");
        vault.lockTokens(0, 1 days);
    }

    function testLockFailsIfDurationZero() public {
        vm.prank(user);
        vm.expectRevert("Lock duration must be greater than zero");
        vault.lockTokens(100 ether, 0);
    }

    function testWithdrawFailsWithInvalidIndex() public {
        vm.prank(user);
        vm.expectRevert("Invalid lock index");
        vault.withdrawTokens(0);
    }

    // --- FUZZ TESTS ---

    function testFuzz_LockAndWithdraw(uint256 amount, uint256 duration) public {
        amount = bound(amount, 1 ether, 100 ether); // Limit fuzz range
        duration = bound(duration, 1, 30 days);

        token.mint(address(this), amount);
        token.approve(address(vault), amount);
        vault.lockTokens(amount, duration);

        vm.warp(block.timestamp + duration + 1);

        vault.withdrawTokens(0);
        assertEq(token.balanceOf(address(this)), amount);
    }

    function testFuzz_LockMultipleEntries(uint256 a1, uint256 a2) public {
        a1 = bound(a1, 1 ether, 50 ether);
        a2 = bound(a2, 1 ether, 50 ether);

        token.mint(user, a1 + a2);
        vm.prank(user);
        token.approve(address(vault), a1 + a2);

        vm.startPrank(user);
        vault.lockTokens(a1, 1 days);
        vault.lockTokens(a2, 2 days);
        vm.stopPrank();

        TimeLockedVault.Lock[] memory locks = vault.getLocks(user);
        assertEq(locks.length, 2);
        assertEq(locks[0].amount, a1);
        assertEq(locks[1].amount, a2);
    }
}
