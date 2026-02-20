//This is a Price converter library from fundMe.sol

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.30;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    //set all to internal
    //because msg.value processes in ether and we are working in usd,hence a need for conversion using stuffs like oracle and chainlink
    //in that light,theres a need to write a functon to get the price of ETH in term of usd and a function to getConversionRate
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        //we'd use chainlink(docs.chain.link)--data feed--fedd addre--price feeds--eth sepolia;copy the address. ABI  could be gotten by the deployment of d contract from chainlink(github chainlink--tag v1.3.0--contract--src/v0.8--interfaces)...copy the code in AggregatorV3Interface,paste in remix and copy the ABI
        // addr=0x694AA1769357215DE4FAC081bf1f309aDC325306
        //ABI
        // (uint80 roundId, int256 price,uint256 startedAt, uint256 timeStamp,uint80 answeredInRound)=priceFeed.latestRoundData();  from aggravator interface;only interested in price
        (, int256 price,,,) = priceFeed.latestRoundData(); //price=price of eth in usd....in form of 100000000000 with 8 zeros but msg.value would have 18 cause 1 eth=1*10**18 wei...we have to get them to align;int256 cause some prices could be negative.solidity doesnt use decimals
        return uint256(price * 1e10); //this is to get both price and msg.value have same decimals...in addition,price is in int but msg.vale in uitn,thus conversion is needed,called typepcasting(check note); should have been  ..return price * 1e10;
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        //to convert msg.value to dolls
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; //we divide by 1e18 to reduce the outcome zeroes,cause both ethPrice and ethAmount are in 1e18
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256) {
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}
