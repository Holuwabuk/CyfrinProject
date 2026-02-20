//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {

        // Anything before the startBroadcast, not a real tnx, so no gas
        HelperConfig helperConfig=new HelperConfig();
        address ethUsdPriceFeed =helperConfig.activeNetworkConfig();    //if we were to return a struct that has diff  data types instead of 1 data type in this scenario,it'd be  (address ethUsdPriceFeed, ,) in a bracket,and only the needed would be written out

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);   //In this,we can change the address of the price feed if we want to hardcode,but cause no harcoding,we wrote a mock contract, HelperConfig
        vm.stopBroadcast();
        return fundMe;
    }
}
