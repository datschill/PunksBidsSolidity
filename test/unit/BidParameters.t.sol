// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../Base.t.sol";

contract BidParameters is Base {

    uint256 public nonce;
    Bid public bid;

    function setUp() public {
        bid = defaultBid();
        bid.bidder = coco;

        nonce = punksBids.nonces(coco);
    }

    // _validateBidParameters
    function testValidateBidParameters() public {
        bytes32 bidHash = punksBids.hashBid(bid, nonce);

        bool areValidParameters = punksBids.validateBidParameters(bid, bidHash);

        assertEq(areValidParameters, true, "Default Bid parameters should be validated");
    }

    function testInvalidBidderNullAddress() public {
        // Bidder == null address
        bid.bidder = address(0);

        bytes32 bidHash = punksBids.hashBid(bid, nonce);

        bool areValidParameters = punksBids.validateBidParameters(bid, bidHash);

        assertEq(areValidParameters, false, "Bidder shouldn't be null address");
    }

    function testInvalidBidCancelled() public {
        // Cancel bid
        vm.prank(coco);
        punksBids.cancelBid(bid);

        bytes32 bidHash = punksBids.hashBid(bid, nonce);

        bool areValidParameters = punksBids.validateBidParameters(bid, bidHash);

        assertEq(areValidParameters, false, "Bid shouldn't be cancelled (or executed)");
    }

    function testInvalidListingTime() public {
        // Listing time >= block.timestamp
        bid.listingTime = block.timestamp;

        bytes32 bidHash = punksBids.hashBid(bid, nonce);

        bool areValidParameters = punksBids.validateBidParameters(bid, bidHash);

        assertEq(areValidParameters, false, "Listing time should be before block timestamp");
    }

    function testInvalidExpirationTime() public {
        // Expiration time <= block.timestamp
        bid.expirationTime = block.timestamp;

        bytes32 bidHash = punksBids.hashBid(bid, nonce);

        bool areValidParameters = punksBids.validateBidParameters(bid, bidHash);

        assertEq(areValidParameters, false, "Expiration time should be after block timestamp");
    }
}


