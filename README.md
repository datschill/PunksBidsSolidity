# About PunksBids

PunksBids is a bidding platform for CryptoPunks, allowing anybody to bid on specific attributes or set of IDs. The go-to website to buy/sell/bid/browse CryptoPunks.

---

# On-chain context

```
DEPLOYMENT: mainnet
ERC20: WETH
NFT collection: CryptoPunks 
```

---

# Requirements

Foundry : https://github.com/foundry-rs/foundry

# Building Contracts

```bash
forge build
```

# Running tests

```bash
make unit-tests
```

# Test Coverage

```bash
forge coverage
```

---

# Audit scope

`src/lib/*`

`src/PunksBids.sol`

---

# Contract In Scope

`lib/*` (222 nSLOC)

`PunksBids.sol` (242 nSLOC)

## Underlying Mechanism

TODO

# Functional specs

TODO

# Technical specs

## User Methods

### Execute Match

`function executeMatch(Input calldata buy, uint256 punkIndex)`

TODO

### Cancel Bid

`function cancelBid(Bid calldata bid)`

TODO

### Cancel Bids

`function cancelBids(Bid[] calldata bids)`

TODO

### Increment Nonce

`function incrementNonce()`

TODO

### Checks

TODO

## Owner Methods

These methods are only callable by the owner of PunksBids.

None of these methods allow the owner to take custody of user's funds or assets at any time.

### Open

`function open()`

TODO

### Close

`function close()`

TODO

### Set Fee Rate

`function setFeeRate(uint16 _feeRate)`

TODO

### Set Local Fee Rate

`function setLocalFeeRate(uint16 _localFeeRate)`

TODO

### Withdraw Fees

`function withdrawFees(address recipient)`

This method is used to withdraw accumulated fees on PunksBids.

---

# Solidity Metrics 

lib/* metrics can be found [here](PunksBidsSolidity/solidity-metrics-lib.html)

PunksBids.sol metrics can be found [here](PunksBidsSolidity/solidity-metrics.html)

---

# Team & Contacts

If you have any questions. Please reach out!

- 0xd0s (Fullstack Blockchain Dev) :
    - GitHub : [@datschill](https://github.com/datschill)
    - Twitter : [@0xd0s1](https://twitter.com/0xd0s1)
    - Discord : 0xd0s
