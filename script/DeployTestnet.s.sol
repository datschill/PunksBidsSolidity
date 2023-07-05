// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Base.s.sol";

import "src/test/GoerliPunksBids.sol";

contract DeployGoerli is Base {
    function setUp() public {}

    function run() external {
        vm.startBroadcast(deployerGoerliPK);

        new GoerliPunksBids();

        vm.stopBroadcast();
    }
}