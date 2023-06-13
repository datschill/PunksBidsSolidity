// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

error NotPayable();

contract RevertFallback {
    fallback() external payable {
        revert NotPayable();
    }

    receive() external payable {
        revert NotPayable();
    }
}
