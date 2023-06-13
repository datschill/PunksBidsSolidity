// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import "src/test/RevertFallback.sol";
import "src/test/TestPunksBids.sol";

import "src/test/interfaces/ITestCryptoPunksMarket.sol";

import "src/interfaces/IWETH.sol";

import {Bid} from "src/lib/BidStructs.sol";

contract Base is EIP712, Test {
    using console for *;

    RevertFallback internal revertFallback;
    TestPunksBids internal punksBids;
    ITestCryptoPunksMarket public punksMarketPlace;

    address weth;
    uint256 internal cocoPK;
    address internal coco;
    uint256 internal dadaPK;
    address internal dada;
    uint256 internal deployerPK;
    address internal deployer;

    uint256 public defaultPunkPrice = 0xffffffffffff;

    constructor() {
        revertFallback = new RevertFallback();
        punksBids = new TestPunksBids();
        punksMarketPlace = ITestCryptoPunksMarket(punksBids.CRYPTOPUNKS_MARKETPLACE());
        string memory NAME = punksBids.NAME();
        string memory VERSION = punksBids.VERSION();
        weth = punksBids.WETH();

        _domainSeparator = _hashDomain(
            EIP712Domain({name: NAME, version: VERSION, chainId: block.chainid, verifyingContract: address(punksBids)})
        );

        cocoPK = vm.envUint("PRIVATE_KEY_COCO");
        coco = vm.addr(cocoPK);
        dadaPK = vm.envUint("PRIVATE_KEY_DADA");
        dada = vm.addr(dadaPK);
        deployerPK = vm.envUint("DEPLOYER_PK_GOERLI");
        deployer = vm.addr(deployerPK);
    }

    function signBid(uint256 privateKey, Bid memory bid, uint256 nonce)
        internal
        view
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        bytes32 bidHash = punksBids.hashBid(bid, nonce);
        bytes32 bidHashToSign = punksBids.hashToSign(bidHash);
        return vm.sign(privateKey, bidHashToSign);
    }

    function defaultBid() internal view returns (Bid memory) {
        return Bid({
            bidder: coco,
            attributesCountEnabled: false,
            attributesCount: 0,
            modulo: 0,
            maxIndex: 0,
            indexes: new uint16[](0),
            excludedIndexes: new uint16[](0),
            baseType: "",
            attributes: "",
            amount: 100000000000000000000,
            listingTime: 0,
            expirationTime: block.timestamp + 1 days,
            salt: 0xfff987,
            nonce: 0
        });
    }
}
