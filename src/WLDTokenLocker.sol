// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IWLDToken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract WLDTokenLocker {
    IWLDToken public wldToken;
    uint256 public minLockDuration;
    uint256 public maxLockDuration;

    struct Lock {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Lock) public locks;

    event TokensLocked(address indexed user, uint256 amount, uint256 unlockTime);
    event TokensWithdrawn(address indexed user, uint256 amount);

    constructor(address _wldTokenAddress, uint256 _minLockDuration, uint256 _maxLockDuration) {
        wldToken = IWLDToken(_wldTokenAddress);
        minLockDuration = _minLockDuration;
        maxLockDuration = _maxLockDuration;
    }

    function lockTokens(uint256 amount, uint256 lockDuration) external {
        require(lockDuration >= minLockDuration, "Lock duration too short");
        require(lockDuration <= maxLockDuration, "Lock duration too long");
        require(wldToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        locks[msg.sender] = Lock({amount: amount, unlockTime: block.timestamp + lockDuration});

        emit TokensLocked(msg.sender, amount, block.timestamp + lockDuration);
    }

    function withdrawTokens() external {
        Lock storage userLock = locks[msg.sender];
        require(block.timestamp >= userLock.unlockTime, "Tokens are still locked");

        uint256 amount = userLock.amount;
        userLock.amount = 0;

        require(wldToken.transferFrom(address(this), msg.sender, amount), "Transfer failed");

        emit TokensWithdrawn(msg.sender, amount);
    }
}
