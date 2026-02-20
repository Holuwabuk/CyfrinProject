//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {Script} from "../lib/forge-std/src/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        vm.startBroadcast();
        SimpleStorage simpleStorage = new SimpleStorage();
        vm.stopBroadcast();
        return simpleStorage;
    }
}

//Anvil deployed contract address: 0x5fbdb2315678afecb367f032d93f642f64180aa3
// Sepolia Contract Address: 0x55868da75e91153cf4b06f4D2d7Af9cF5E860179
