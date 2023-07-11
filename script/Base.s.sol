// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

contract Base is Script {
    using console for *;

    address internal deployerGoerli;
    uint256 internal deployerGoerliPK;
    address internal deployerMainnet;
    uint256 internal deployerMainnetPK;

    constructor() {
        deployerGoerliPK = vm.envUint("DEPLOYER_PK_GOERLI");
        deployerGoerli = vm.addr(deployerGoerliPK);
        deployerMainnetPK = vm.envUint("DEPLOYER_PK_MAINNET");
        deployerMainnet = vm.addr(deployerMainnetPK);
    }
}