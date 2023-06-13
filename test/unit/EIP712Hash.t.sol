// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../Base.t.sol";

contract EIP712Hash is Base {

    bytes32 constant TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    function testHashDomain() public {
        string memory NAME = punksBids.NAME();
        string memory VERSION = punksBids.VERSION();

        bytes32 hashDomainPunksBids = punksBids.hashDomain(EIP712Domain({
            name: NAME,
            version: VERSION,
            chainId: block.chainid,
            verifyingContract: address(punksBids)
        }));

        bytes32 hashDomain = keccak256(
            abi.encode(
                TYPEHASH,
                keccak256(bytes(NAME)),
                keccak256(bytes(VERSION)),
                block.chainid,
                address(punksBids)
            )
        );

        assertEq(hashDomainPunksBids, hashDomain, "EIP712Domain should be correctly hashed");
    }
}


