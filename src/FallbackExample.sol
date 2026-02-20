// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract FallbackExample {
    uint256 public result;

    receive() external payable {
        //receive is a special function,hence solidity knows it and so,no need to pt function. it gets triggered when someone execute a function that doesnt exist in the code
        result = 1; // 1 would be triggered if you dont include a particular amount in the wei part to specify how much
    }

    fallback() external payable {
        result = 2;
    }
}
