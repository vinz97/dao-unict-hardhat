# DAO Unict Hardhat

This repository contains the backend part of a decentralized university management system, based on blockchain and smart contracts. The goal of this project is to create a Dapp that performs all the typical functions that are carried out by students, professors, administrative staff, etc. and replace the centralized approach that is currently used by universities.

## Features

The backend is responsible for the following tasks:
- Deploying the DAO contract and verifying it with block confirmations
- Updating the frontend by communicating the address and the ABI of the deployed contract
- Testing the contract functions

## Technologies

The backend is mainly developed using NodeJS, and the following libraries and frameworks have been used:
- [Ethers](https://github.com/ethers-io/ethers.js/) for interacting with Ethereum blockchain
- [Hardhat](https://github.com/nomiclabs/hardhat) for compiling and testing smart contracts

The smart contracts are developed using Solidity.

## Getting Started

To get started with this project, you should have Node.js and npm installed on your machine.

1. Clone this repository:

```bash
git clone https://github.com/vinz97/dao-unict-hardhat.git
```

2. Install the dependencies:

```bash
npm install
```

3. Compile the smart contracts:
```bash
npx hardhat compile
```

4. Test the smart contracts:
```bash
npx hardhat test
```

5. Deploy the smart contracts:
```bash
npx hardhat run scripts/deploy.js
```

## Contributing

Contributions are always welcome! Please feel free to open an issue or a pull request if you find any bugs or want to suggest new features.

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).








