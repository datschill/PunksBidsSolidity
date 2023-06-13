// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ICryptoPunksData {
    /**
     * @dev Retrieve base type and attributes of a Punk, separated by a comma in a single string
     * @param index Punk Index
     */
    function punkAttributes(uint16 index) external view returns (string memory);
}
