// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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
        (uint8 v, bytes32 r, bytes32 s) = signHash(cocoPK, bidHashToSign);

        Input memory input = Input({
            bid: bid,
            v: v,
            r: r,
            s: s
        });

        bool isValidSignature = punksBids.validateSignature(input, bidHash);

        assertEq(isValidSignature, true, "Bid signature should be valid");
    }

    function testValidateSignatureIfSenderIsBidder() public {
        bytes32 bidHash = punksBids.hashBid(bid, nonce);
        bytes32 bidHashToSign = punksBids.hashToSign(bidHash);
        // Signer != Bidder
        (uint8 v, bytes32 r, bytes32 s) = signHash(dadaPK, bidHashToSign);

        Input memory input = Input({
            bid: bid,
            v: v,
            r: r,
            s: s
        });

        // Msg.sender == Bidder
        vm.prank(coco);
        bool isValidSignature = punksBids.validateSignature(input, bidHash);

        assertEq(isValidSignature, true, "Bid signature should be considered valid if msg.sender is biddder");
    }

    function testCannotValidateIncorrectSignature() public {
        bytes32 bidHash = punksBids.hashBid(bid, nonce);
        bytes32 bidHashToSign = punksBids.hashToSign(bidHash);
        // Signer != Bidder
        (uint8 v, bytes32 r, bytes32 s) = signHash(dadaPK, bidHashToSign);

        Input memory input = Input({
            bid: bid,
            v: v,
            r: r,
            s: s
        });

        bool isValidSignature = punksBids.validateSignature(input, bidHash);

        assertEq(isValidSignature, false, "Bid signature shouldn't be considered valid if signer != biddder");
    }

    function testVCannotBeInvalid(uint8 v) public {
        vm.assume(v != 27 && v != 28);
        bytes32 bidHash = punksBids.hashBid(bid, nonce);
        bytes32 bidHashToSign = punksBids.hashToSign(bidHash);
        (, bytes32 r, bytes32 s) = signHash(cocoPK, bidHashToSign);

        Input memory input = Input({
            bid: bid,
            v: v,
            r: r,
            s: s
        });

        vm.expectRevert("Invalid v parameter");
        punksBids.validateSignature(input, bidHash);
    }
}


