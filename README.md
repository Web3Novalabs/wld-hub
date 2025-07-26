## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

alchemy sepolia rpc url

<!-- https://eth-sepolia.g.alchemy.com/v2/${key} -->


Updated README file

////////

# 🧠 TimeLockedVault

A TimeLockedVault smart contract that allows users to deposit ERC20 tokens with a time lock. Users can only withdraw their tokens after the lock period has passed.

✅ Features:

- Lock ERC20 tokens for a fixed duration.

- Prevent early withdrawals.

- Fully tested using Foundry's Forge framework.
## ✍️ Project Structure Update
This repository includes a custom smart contract called TimeLockedVault.sol, created as part of a feature implementation for locking ERC-20 token deposits with time-based withdrawal restrictions.

📄 File: src/TimeLockedVault.sol

This contract allows users to:

- Deposit ERC-20 tokens with a lock duration

- Enforce time-based withdrawal logic

- Access locked balances and check unlock time

Unit tests are provided in test/TimeLockedVault.t.sol.
## 🧪 How to Run the Tests:

To run tests, run the following command

```bash
  forge test --match-path test/TimeLockedVault.t.sol
```

Ensure your .env is set up with RPC URL and private key if needed.
## 📁 Files:
- Contract: src/TimeLockedVault.sol

- Test: test/TimeLockedVault.t.sol
## 🛠 Technologies:
- Solidity ^0.8.20

- Foundry (Forge)
## ✅ Optional (only if you add a script):
If you decide to write a deploy script later (like TimeLockedVault.s.sol)

```bash
  forge script script/TimeLockedVault.s.sol:TimeLockedVaultScript --rpc-url <your_rpc_url> --private-key <your_private_key>

```

////////
