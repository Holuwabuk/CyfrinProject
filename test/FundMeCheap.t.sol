//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/FundMe.s.sol"; //such that when we update address in Script,wed not need do so here again

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BAL = 100 ether;
    uint256 constant GAS_PRICE = 1;     //could be any value actually

    function setUp() external {
        //us--FundMeTest--FundMe. we call FundMeTest,which then deploys the FundMe contract;so FundMeTest is the owner,not us
        // fundMe = new FundMe(); //constructor takes no input
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); //run in script will return a FundMe contract
        vm.deal(USER, STARTING_BAL);
    }

    function testMinimumDollarisFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        //assertEq(fundMe.i_owner(), address(this)); FundMeTest is the caller,hence the msg.sender that deployed,we are the msg.sender that called FundMe...so wed enter address(this) as msg.sender
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionAccurate() public {
        //hardcoded with a sepolia address. forge would automatically use anvil,hence the test will fail. To make it pass,youd use fork testing using "forge test --mt testPriceFeedVersionAccurate -vv --fork-url $SEPOLIA_RPC_URL" after source .env
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert("Insufficient Funds"); //lets a failing test pass
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); //this address is the caller of the FundMe contract. if i had user1,user2 and i pranked....totally diff;;;Get the amount that address(this) funded from the FundMe contract's mapping, and save it in amountFunded.
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFundersToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0); //new tests restart setUp function,b4 it's ran...so first funder gets reset to zero index
        assertEq(funder, USER);
    }

    modifier funded (){             //if you must do different funding,instead of repeating them over and over in your test function,you can have a modifier where the tests are run/simulated,and modifier added to test
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }


    function testOnlyOwnerCanWithdraw () public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }
    
    function testWithdrawWithASingleFunder () public funded {
       //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance,endingOwnerBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded{
            //arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;        //starting with 1 cause sometimes,d zero address reverts and doesnt let you do stuffs

        for(uint160 i= startingFunderIndex; i < numberOfFunders; i++){
            // vm.prank, vm.deal new address and fund the fundMe
            // hoax pranks an address and also funds it.Does both prank and deal 2geda
            //uint160 has same amt of bytes as an address,hence used to generate addresses

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
            //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.CheaperWithdraw();                  
        vm.stopPrank();
            //Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance,fundMe.getOwner().balance);   //we didnt define ending bal

    }

}
