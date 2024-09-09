# DAO Smart Contract

This project contains a smart contract named "DAO" developed in Solidity and deployed using Hardhat. The contract enables the creation and management of a decentralized autonomous organization (DAO) where users can buy shares, vote on proposals, and participate in governance.

## Overview

The project is a **Decentralized Governance System** that leverages blockchain technology to enable decentralized decision-making through a DAO. It features a smart contract that allows users to buy shares, create proposals, and vote on them using a weighted voting system. The project supports both **Direct** and **Liquid Democracy** models.

Key features include:

- **Share Purchase**: Users can buy shares to participate in the governance process.
- **Proposals**: Members can create proposals for the DAO, which other members can vote on.
- **Voting**: Weighted voting system based on the number of shares owned.
- **Delegated Voting**: In Liquid Democracy, members can delegate their vote to others.

The smart contract is implemented with **Solidity** and is tested using the **Hardhat** framework.

## Technical Choices

### Language and Tools

- **Solidity**: Solidity is used to implement the smart contract due to its compatibility with Ethereum-based systems.
- **Hardhat**: Hardhat was used as the development environment for compiling, testing, and deploying the contract.
- **OpenZeppelin**: OpenZeppelin libraries were used to implement secure and standardized ERC20 functionality.
- **TypeScript**: TypeScript was used to create unit tests and manage the interactions with the smart contract.

### Contract Architecture

The project consists of two main contracts:

1. **DAO.sol**: This contract manages the DAO logic, including roles, shares, proposals, and voting.
2. **ERC20Mock.sol**: A mock ERC20 contract used to simulate token-based transactions within the DAO.

### Main Features

- **Buy Shares**: Users can purchase shares using an ERC20 token, which allows them to participate in DAO governance.
- **Proposals and Voting**: Members can create and vote on proposals. Votes are weighted based on the number of shares held.
- **Delegated Voting**: In liquid governance, members can delegate their vote to another member.

## Project Structure

- **contracts/DAO.sol**: Contains the main DAO contract that manages roles, shares, proposals, and voting logic.
- **contracts/ERC20Mock.sol**: A mock ERC20 token contract for testing purposes.
- **test/DAO.test.ts**: Unit tests for the DAO contract, written in TypeScript using Hardhat.

## How to Use

1. Clone the repository:

```sh
git clone https://github.com/stampcodes/DAO.git
```

2. Navigate to the project directory:

```sh
cd DAO
```

3. Install the necessary dependencies:

```sh
npm install
```

4. Compile the contracts using Hardhat:

```sh
npx hardhat compile
```

5. Run the tests:

```sh
npx hardhat test
```

6. Deploy the contract on a test network (e.g., Sepolia or a local Hardhat network):

```sh
npx hardhat run scripts/deploy.ts --network sepolia
```

7. Verify the contract on Etherscan using Hardhat:

```sh
npx hardhat verify --network sepolia <contract_address> <constructor_arguments>
```

## Testing

The project includes a set of unit tests written in TypeScript to verify the core functionalities of the DAO contract. These tests cover the following scenarios:

- Users can buy shares and become members.
- Proposals can be created and voted on by members.
- Voting is weighted according to the number of shares held by each member.
- Delegated voting is functional in Liquid Democracy governance mode.

To run the tests:

```sh
npx hardhat test
```

## Licence

Distributed under the MIT License. See LICENSE for more information.

## Contact

For more information, you can contact:

- **Name**: Andrea Fragnelli
- **Project Link**: [https://github.com/stampcodes/DAO.git](https://github.com/stampcodes/DAO.git)
