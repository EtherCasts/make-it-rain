# Make It Rain
============

A decentralized tipping system on Ethereum that splits tips between a designated recipient and random previous tippers.

## Original version (implemented in LLL)

https://ethercasts.github.io/make-it-rain/make-it-rain.html

## Overview

Make It Rain is a smart contract that creates a community-driven tipping ecosystem. When you send a tip, 50% goes directly to your chosen recipient, and the other 50% is randomly distributed among previous participants. Anyone who sends or receives a tip becomes a member, making them eligible to receive a portion of future tips.

## How It Works

1. **Sending Tips**: Send Ether to the contract along with a designated recipient address
2. **50/50 Split**: Half of your tip goes directly to your chosen recipient
3. **Random Distribution**: The other half is evenly distributed among 5 randomly selected previous members (configurable)
4. **Automatic Membership**: Both senders and recipients automatically become members and eligible for future random tips
5. **Claiming Rewards**: Members can claim their accumulated tips at any time while maintaining membership

## Features

- **Balanced Distribution**: 50% direct tipping, 50% community reward system
- **Fair Randomization**: Uses blockchain-based randomization to select recipients
- **Configurable Distribution**: Admin can adjust the number of random recipients to optimize for gas costs
- **Automatic Membership**: Anyone who sends or receives a tip automatically joins the pool
- **Simple Claiming**: One-click function to withdraw your accumulated tips
- **Detailed Events**: Emits events for tips, distributions, and claims for transparency
- **Statistics Tracking**: Records total tips, distributions, and amounts

## Technical Details

- Built on Ethereum using Solidity 0.8.20
- Randomization based on block hashes for fair selection
- Efficient member tracking and balance management
- Integrated with ENS (Ethereum Name Service) for discoverability
- Admin functionality for configuration and contract management
- Gas-optimized to balance distribution fairness with transaction costs

## Example Scenario

1. Alice sends a 1 ETH tip to Bob
2. 0.5 ETH goes directly to Bob's balance
3. The other 0.5 ETH is divided among 5 random previous members (0.1 ETH each)
4. Both Alice and Bob are now members and eligible to receive random portions of future tips
5. Charlie sends a 0.4 ETH tip to Dave
6. Alice, Bob, or both might receive a portion of the 0.2 ETH community distribution

## Usage

### To Make It Rain:

```solidity
// Send a tip with default settings (5 random recipients)
contract.makeItRain.value(amountInWei)(recipientAddress);

// Or specify the number of random recipients
contract.makeItRain.value(amountInWei)(recipientAddress, numberOfRandomRecipients);
```

### To Claim Your Tips:

```solidity
contract.claim();
```

## Gas Costs and Recommendations

Based on analysis, the gas costs for different numbers of random recipients are:

| Random Recipients | Est. Gas Cost | ETH Cost (50 Gwei) | % of 1 ETH |
|-------------------|---------------|---------------------|------------|
| 1                 | 41,500        | 0.00208             | 0.21%      |
| 5                 | 63,500        | 0.00318             | 0.32%      |
| 10                | 91,000        | 0.00455             | 0.46%      |

For most use cases, 5 random recipients provides a good balance between distribution fairness and gas costs. The contract defaults to 5 recipients but allows the admin to adjust this based on network conditions.

## Installation

1. Deploy the contract to Ethereum mainnet or testnet
2. Interact with the contract using a wallet like MetaMask or any web3 interface
3. Start tipping and potentially receiving random tips from others!

## License

MIT License

Tip Ether to random people who have previously tipped.
After this you are added to the member list and can collect tips.


Inspired by The Doge Tipping App - http://youtu.be/1MSzYjHPNS0
