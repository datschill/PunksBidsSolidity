// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Base.s.sol";

import "src/PunksBids.sol";

contract DeployMainnet is Base {
    function setUp() public {}

    function run() external {
        vm.startBroadcast(deployerMainnetPK);

        new PunksBids();

        vm.stopBroadcast();
    }
}