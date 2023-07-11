# About PunksBids

PunksBids is a bidding platform for CryptoPunks, allowing anybody to bid on specific attributes or set of IDs. The go-to website to buy/sell/bid/browse CryptoPunks.

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
make coverage
```

---

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

# Audit

Smart contracts were audited by [pashov](https://twitter.com/pashovkrum).

Audit report can be found [here](https://github.com/pashov/audits/blob/master/solo/PunksBids-security-review.md).

All issues but L-02 were fixed.

---

# Team & Contacts

If you have any questions. Please reach out!

- 0xd0s (Fullstack Blockchain Dev) :
    - GitHub : [@datschill](https://github.com/datschill)
    - Twitter : [@0xd0s1](https://twitter.com/0xd0s1)
    - Discord : 0xd0s
