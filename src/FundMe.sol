//Goal is to get funds from users,withdraw funds, set a minimum funding value in usd

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.30;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "../src/PriceConverter.sol";

//using custom error,declared outside the main contract
error Fundme_NotOwner();

contract FundMe {
    //to attach all the functions in priceconverter to uint256,wed say
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18; //we used e18 cause after our conversion and all,the amount returned would be in e18 ;since it is only used once,and never changed,you can add "constant" to reduce gas,when used,you use cap letter and _ if needed
    address[] private s_funders; //s_ to show storage var
    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;

    address private immutable i_owner; //variables set once but outside of the same line they are declared ,we can mark immutable and we use i_... to show it's immutable
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // when working with a library,the first input variable becomes the type youd use for the library. In price converter,uint256 ethAmount is the input; for the fundme.sol,msg.value is a uint256 that can call the getPriceConverter function,hence used as msg.value.getConversionRate
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Insufficient Funds"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] =
            s_addressToAmountFunded[msg.sender] +
            msg.value; //for folks who fund more than once::: also,instead of this method,you can do addressToAmountFunded[msg.sender] += msg.value; instead of having sth=sth+another value
    }

    function CheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length; //This way,we'd only read from storage once,irrespective of the loop length; the rest loop reads from memory
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    function withdraw() public onlyOwner {
        //using for loop::  for (starting index, ending index, step amount)
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            //to access the zero(th) element of our funders array,we say funders[funderIndex]
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0; //resetting all money to zero cause were withdrawing all d money
        }
        //Reset the array with the new keyword
        s_funders = new address[](0);

        //withdraw :Transfer,call and send. transfer automatically reverts if failed,but send would only do that if we had a require statement
        //transfer
        //msg.sender is a type address while payable(msg.sender) is a payable address
        //payable(msg.sender).transfer(address(this).balance); //this: this whole contract
        //OR
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);  require(sendSuccess, "Transaction failed");
        //call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    //Not needed,just for testing; imported the aggregatorV3 for this too
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    //we want only the owner to be able to withdraw,however,in cases where we have other functions only owner can call,instead of adding  require (msg.sender ==owner, "You are not the Owner"); to everything,we can use modifiers
    modifier onlyOwner() {
        // require (msg.sender == i_owner, "You are not Owner!");    you could use if revert to save gas

        if (msg.sender != i_owner) {
            //using custom error
            revert Fundme_NotOwner();
        }
        _; // _; means add whatever else you wantu do. its position matters,if above the require statement, it will execute the code inside the function first before the require. so it matters
    }

    //what happens if someone sends eth to this contract withot using the fund function: this brings us to special functions, recieve and fallback

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
