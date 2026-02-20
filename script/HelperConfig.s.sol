//1. Deploy mocks when we are on a local anvil chain
//2. Keep track of contract addresess across different chains

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {Script,console} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //If we are on a local anvil, we deploy mocks;otherwise grab the existing address from the live network. Doing this,we don't have to hardcode the address in the script

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS=8;
    int256 public constant INITIAL_PRICE=2000e8;

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetEthConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        }); //need the mainnet address from chainlink data feed for ethusd,can also create an app for the mainnet on chainlink for customized API key
        return mainnetEthConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {         //Gas optimization to prevent multiple deployment of the below...
            return activeNetworkConfig;
        }
        //1.Deploy the mock 2.return the mock address
        vm.startBroadcast();       //cause of the vm,emoved the pure,and to accessthe vm keyword,we added 'is script' to the contract declaration
        MockV3Aggregator mockPriceFeed=new MockV3Aggregator(DECIMALS, INITIAL_PRICE);    //the   constructor(uint8 _decimals, int256 _initialAnswer) takes two input parameters. Dec for eth is 8,we assumed 2000e8
        vm.stopBroadcast();

        NetworkConfig memory anvilEthConfig = NetworkConfig ({priceFeed: address(mockPriceFeed)});
        return anvilEthConfig;
    }
}
