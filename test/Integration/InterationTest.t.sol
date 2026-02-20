//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/FundMe.s.sol"; //such that when we update address in Script,wed not need do so here again
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract Interaction is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BAL = 100 ether;
    uint256 constant GAS_PRICE = 1; 

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); //run in script will return a FundMe contract
        vm.deal(USER, STARTING_BAL);
       }

    function testUserCanFundInteraction () public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

}
}