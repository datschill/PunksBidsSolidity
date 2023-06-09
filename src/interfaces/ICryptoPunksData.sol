// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ICryptoPunksData {
    function punkAttributes(uint16 index)
        external
        view
        returns (string memory);
}