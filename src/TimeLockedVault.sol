// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title TimeLockedVault
/// @notice Vault to deposit WLD tokens and lock them for a user-defined time period.
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TimeLockedVault {
    IERC20 public immutable wldToken;

    struct Lock {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Lock[]) public userLocks;

    event TokensLocked(address indexed user, uint256 amount, uint256 unlockTime);
    event TokensWithdrawn(address indexed user, uint256 amount);

    constructor(address _wldTokenAddress) {
        require(_wldTokenAddress != address(0), "Invalid token address");
        wldToken = IERC20(_wldTokenAddress);
    }

    /// @notice Lock tokens for a specified duration
    /// @param amount Amount of tokens to lock
    /// @param lockDuration Duration in seconds to lock tokens
    function lockTokens(uint256 amount, uint256 lockDuration) external {
        require(amount > 0, "Amount must be greater than zero");
        require(lockDuration > 0, "Lock duration must be greater than zero");

        bool success = wldToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        uint256 unlockTime = block.timestamp + lockDuration;
        userLocks[msg.sender].push(Lock(amount, unlockTime));

        emit TokensLocked(msg.sender, amount, unlockTime);
    }

    /// @notice Withdraw tokens if the lock time has expired
    /// @param index Index of the user's lock to withdraw
    function withdrawTokens(uint256 index) external {
        require(index < userLocks[msg.sender].length, "Invalid lock index");

        Lock memory lock = userLocks[msg.sender][index];
        require(block.timestamp >= lock.unlockTime, "Tokens are still locked");

        // Remove the lock entry by swapping with the last and popping
        uint256 amount = lock.amount;
        uint256 lastIndex = userLocks[msg.sender].length - 1;
        if (index != lastIndex) {
            userLocks[msg.sender][index] = userLocks[msg.sender][lastIndex];
        }
        userLocks[msg.sender].pop();

        bool success = wldToken.transfer(msg.sender, amount);
        require(success, "Token transfer failed");

        emit TokensWithdrawn(msg.sender, amount);
    }

    /// @notice Get all lock records for a user
    function getLocks(address user) external view returns (Lock[] memory) {
        return userLocks[user];
    }
}
