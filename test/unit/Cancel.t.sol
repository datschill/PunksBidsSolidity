// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../Base.t.sol";

contract Cancel is Base {
    event BidCancelled(bytes32 hash);

    Bid public bidCoco;
    bytes32 public hashBidCoco;
    Bid public nextBidCoco;
    bytes32 public hashNextBidCoco;

    Bid[] public bids;
    bytes32[] public hashes;

    function setUp() public {
        uint256 nonce = punksBids.nonces(coco);

        bidCoco = defaultBid();
        bidCoco.bidder = coco;
        hashBidCoco = punksBids.hashBid(bidCoco, nonce);

        nextBidCoco = defaultBid();
        nextBidCoco.bidder = coco;
        nextBidCoco.amount += 1;
        hashNextBidCoco = punksBids.hashBid(nextBidCoco, nonce);

        bids.push(bidCoco);
        bids.push(nextBidCoco);
        
        hashes.push(hashBidCoco);
        hashes.push(hashNextBidCoco);
    }

    // cancelBid
    function testBidNotCancelledOrFilled() public {
        bool cancelledOrFilled = punksBids.cancelledOrFilled(hashBidCoco);

        assertEq(cancelledOrFilled, false, "Bid shouldn't be cancelled");
    }

    function testBidCancelled() public {
        vm.prank(coco);
        punksBids.cancelBid(bidCoco);

        bool cancelledOrFilled = punksBids.cancelledOrFilled(hashBidCoco);

        assertEq(cancelledOrFilled, true, "Bid should have been cancelled");
    }

    function testCannotCancelBid() public {
        vm.expectRevert("Not sent by bidder");
        punksBids.cancelBid(bidCoco);
    }

    function testCannotCancelBidCancelled() public {
        vm.startPrank(coco);
        punksBids.cancelBid(bidCoco);

        vm.expectRevert("Bid cancelled or filled");
        punksBids.cancelBid(bidCoco);
        vm.stopPrank();
    }

    // TODO : testCannotCancelBidExecuted

    function testEmitBidCancelled() public {
        vm.startPrank(coco);
        vm.expectEmit(false, false, false, true);
        emit BidCancelled(hashBidCoco);
        punksBids.cancelBid(bidCoco);
        vm.stopPrank();
    }
    
    // cancelBids
    function testBidsCancelled() public {
        vm.prank(coco);
        punksBids.cancelBids(bids);

        bool cancelledOrFilled = punksBids.cancelledOrFilled(hashBidCoco);
        bool nextCancelledOrFilled = punksBids.cancelledOrFilled(hashNextBidCoco);

        assertEq(cancelledOrFilled && nextCancelledOrFilled, true, "Bids should have been cancelled");
    }

    function testCannotCancelBids() public {
        vm.expectRevert("Not sent by bidder");
        punksBids.cancelBids(bids);
    }

    function testEmitBidCancelledEvents() public {
        vm.startPrank(coco);

        for (uint256 i = 0; i < hashes.length; i++) {
            vm.expectEmit(false, false, false, true);
            emit BidCancelled(hashes[i]);
        }

        punksBids.cancelBids(bids);

        vm.stopPrank();
    }
}


