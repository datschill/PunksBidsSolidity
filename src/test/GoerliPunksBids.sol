// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/PunksBids.sol";

contract GoerliPunksBids is PunksBids {

    address public constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address public constant CRYPTOPUNKS_MARKETPLACE = 0xac804892C47502Ce8a3e5719E3BF504265Ef5568;
    address public constant CRYPTOPUNKS_DATA = 0x833876299043A1145D4c02C8487bCbBd4Fa9F22F;

}
