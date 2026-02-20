FundMe
A decentralized crowdfunding smart contract built with Solidity and Foundry. Users can fund the contract with ETH, and only the owner can withdraw the funds.

Features

Fund the contract with ETH
Minimum funding amount enforced via Chainlink Price Feeds (USD)
Only the contract owner can withdraw
Supports Sepolia testnet and zkSync

Requirements

Foundry
foundryup-zksync (for zkSync support)

Setup
Clone the repo and install dependencies:
bashgit clone https://github.com/Holuwabuk/CyfrinProject.git
cd CyfrinProject
forge install
Set up your environment variables by creating a .env file:
PRIVATE_KEY=your_private_key
SEPOLIA_RPC_URL=your_sepolia_rpc_url
ETHERSCAN_API_KEY=your_etherscan_api_key
Usage
Build
bashmake build
Test
bashforge test
Deploy to Sepolia
bashmake deploy-sepolia
Deploy to zkSync
bashforge script script/FundMe.s.sol:DeployFundMe --zksync --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
Contract Overview

FundMe.sol — Main contract. Accepts ETH funding and allows owner withdrawal
DeployFundMe.s.sol — Deployment script
HelperConfig.s.sol — Manages network config and Chainlink price feed addresses

License: MIT