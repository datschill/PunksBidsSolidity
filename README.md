# PunksBids

---

## Install
```
$> forge install
```

---

## Run

### LOCAL
Launch local node (mainnet-fork)
```
$> make fork-mainnet
```
Deploy PunksBids on the local network
```
$> make script-deploy-local
```

Retrieve address in the console
```
Contract created: <PUNKSBIDS_ADDRESS>
```
And replace var in .env file with it
```
PUNKSBIDS_LOCAL=<PUNKSBIDS_ADDRESS>
```