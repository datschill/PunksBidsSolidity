// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

contract Base is Script {
    using console for *;

    address internal deployerGoerli;
    uint256 internal deployerGoerliPK;

    constructor() {
        deployerGoerliPK = vm.envUint("DEPLOYER_PK_GOERLI");
        deployerGoerli = vm.addr(deployerGoerliPK);
    }
}