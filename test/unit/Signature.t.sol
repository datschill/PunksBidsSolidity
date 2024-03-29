// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../Base.t.sol";

contract Signature is Base {
    uint256 public nonce;
    Bid public bid;

    function setUp() public {
        bid = defaultBid();
        bid.bidder = coco;

        nonce = punksBids.nonces(coco);
    }

    // _validateSignature
    function testValidateSignature() public {
        bytes32 bidHash = punksBids.hashBid(bid, nonce);
        bytes32 bidHashToSign = punksBids.hashToSign(bidHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(cocoPK, bidHashToSign);

        Input memory input = Input({bid: bid, v: v, r: r, s: s});

        bool isValidSignature = punksBids.validateSignature(input, bidHash);

        assertEq(isValidSignature, true, "Bid signature should be valid");
    }

    function testValidateSignatureIfSenderIsBidder() public {
        bytes32 bidHash = punksBids.hashBid(bid, nonce);
        bytes32 bidHashToSign = punksBids.hashToSign(bidHash);
        // Signer != Bidder
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(dadaPK, bidHashToSign);

        Input memory input = Input({bid: bid, v: v, r: r, s: s});

        // Msg.sender == Bidder
        vm.prank(coco);
        bool isValidSignature = punksBids.validateSignature(input, bidHash);

        assertEq(isValidSignature, true, "Bid signature should be considered valid if msg.sender is biddder");
    }

    function testCannotValidateIncorrectSignature() public {
        bytes32 bidHash = punksBids.hashBid(bid, nonce);
        bytes32 bidHashToSign = punksBids.hashToSign(bidHash);
        // Signer != Bidder
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(dadaPK, bidHashToSign);

        Input memory input = Input({bid: bid, v: v, r: r, s: s});

        bool isValidSignature = punksBids.validateSignature(input, bidHash);

        assertEq(isValidSignature, false, "Bid signature shouldn't be considered valid if signer != biddder");
    }

    function testVerifySignature(uint256 privateKey) public {
        vm.assume(privateKey != 0 && privateKey <= 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140);

        address signer = vm.addr(privateKey);
        bid.bidder = signer;
        nonce = punksBids.nonces(signer);

        bytes32 bidHash = punksBids.hashBid(bid, nonce);
        bytes32 bidHashToSign = punksBids.hashToSign(bidHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, bidHashToSign);

        Input memory input = Input({bid: bid, v: v, r: r, s: s});

        assertEq(punksBids.validateSignature(input, bidHash), true, "Signer should be properly recovered");
    }
}
