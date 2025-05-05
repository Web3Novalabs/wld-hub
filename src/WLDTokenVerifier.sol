// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IWLDToken {
    function balanceOf(address account) external view returns (uint256);
}

contract WLDTokenVerifier {
    IWLDToken public wldToken;
    uint256 public minimumBalance;

    event AccessGranted(address indexed user);
    event AccessDenied(address indexed user);

    constructor(address _wldTokenAddress, uint256 _minimumBalance) {
        wldToken = IWLDToken(_wldTokenAddress);
        minimumBalance = _minimumBalance;
    }

    function verifyAccess(address user) public returns (bool) {
        uint256 balance = wldToken.balanceOf(user);
        if (balance >= minimumBalance) {
            emit AccessGranted(user);
            return true;
        } else {
            emit AccessDenied(user);
            return false;
        }
    }
}
