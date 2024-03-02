# BitHub

This repository contains smart contract code for a decentralized application (dApp) called BitHub. Bithub Contribution Tracker is a platform that incentivizes developers to make contributions to open-source projects by rewarding them with Bithub tokens (BTH), an ERC20 token.

## Contracts

### Bithub

`Bithub.sol` is an ERC20 token contract that implements the standard ERC20 interface along with additional functionalities such as transferring tokens, approving spender addresses, and checking allowances.

### ContributionTracker

`ContributionTracker.sol` is the main contract that tracks and rewards contributions made by developers to open-source projects. It includes functionalities such as recording contributions, claiming rewards, staking tokens, adjusting reward parameters, and withdrawing funds.

## Functionality

- **Recording Contributions**: Approved contributors can record their contributions by providing the repository URL and type of contribution. Upon recording, the contributor is rewarded with Bithub tokens based on a reward tier system.

- **Claiming Rewards**: Contributors can claim their accumulated rewards at any time. Once claimed, the corresponding amount of Bithub tokens is transferred to the contributor's address.

- **Staking**: Users can stake their Bithub tokens in the contract to participate in governance or earn additional rewards. Staked tokens are locked in the contract until unstaked.

- **Reward Adjustment**: Governors have the authority to adjust reward parameters such as base reward and bonus reward, with a cooldown period between adjustments.

- **Withdrawal of Funds**: Contract owner can withdraw excess funds (excluding rewards) accumulated in the contract.

## Usage

1. **Deploy Contracts**: Deploy `Bithub.sol` and `ContributionTracker.sol` contracts on the Ethereum blockchain.

2. **Approve Contributors**: Contract owner can approve or remove contributors by calling `approveContributor` and `removeContributor` functions.

3. **Record Contributions**: Approved contributors can record their contributions by calling the `recordContribution` function with the repository URL and contribution type.

4. **Claim Rewards**: Contributors can claim their accumulated rewards by calling the `claimReward` function.

5. **Adjust Reward Parameters**: Governors can adjust reward parameters using the `adjustRewardParameters` function.

6. **Stake Tokens**: Users can stake their Bithub tokens by calling the `stake` function.

7. **Unstake Tokens**: Users can unstake their tokens by calling the `unstake` function.

8. **Withdraw Funds**: Contract owner can withdraw excess funds by calling the `withdrawFunds` function.
