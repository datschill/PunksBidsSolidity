// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../Base.t.sol";

contract BuyPunk is Base {
    event BidMatched(
        address indexed maker,
        address indexed taker,
        Bid bid,
        uint256 price,
        bytes32 bidHash
    );

    ICryptoPunksMarket public punksMarketPlace;

    uint256 public nonce;
    Bid public bid;
    bytes32 public bidHash;
    bytes32 public bidHashToSign;
    Input public input;

    uint256 punkIndex = 1234;
    address seller;
    uint256 public defaultPunkPrice = 0xffffffffffff;

    function setUp() public {
        punksMarketPlace = ICryptoPunksMarket(punksBids.CRYPTOPUNKS_MARKETPLACE());

        bid = defaultBid();
        bid.bidder = coco;
        bid.amount = 2 * defaultPunkPrice; // Take account of fees

        nonce = punksBids.nonces(coco);

        deal(weth, coco, bid.amount);
        vm.prank(coco);
        IWETH(weth).approve(address(punksBids), bid.amount);

        bidHash = punksBids.hashBid(bid, nonce);
        bidHashToSign = punksBids.hashToSign(bidHash);
        (uint8 v, bytes32 r, bytes32 s) = signHash(cocoPK, bidHashToSign);

        input = Input({
            bid: bid,
            v: v,
            r: r,
            s: s
        });

        seller = _offerPunkForSale(punkIndex, defaultPunkPrice, false);
    }

    function _offerPunkForSale(uint256 punkIndex, uint256 price, bool isLocal) internal returns (address seller) {
        address toAddress = isLocal ? address(punksBids) : address(0);
        seller = punksMarketPlace.punkIndexToAddress(punkIndex);
        vm.prank(seller);
        punksMarketPlace.offerPunkForSaleToAddress(punkIndex, price, toAddress);
    }

    // executeMatch
    function testBidIsFlaggedAsFilled() public {
        punksBids.executeMatch(input, punkIndex);

        bool filled = punksBids.cancelledOrFilled(bidHash);

        assertEq(filled, true, "Bid should be flagged as filled");
    }

    function testShouldHaveEarnedFees() public {
        uint256 finalPrice = punksBids.getFinalPrice(defaultPunkPrice, false);
        uint256 fees = finalPrice - defaultPunkPrice;

        uint256 balanceBefore = address(punksBids).balance;
        punksBids.executeMatch(input, punkIndex);
        uint256 balanceAfter = address(punksBids).balance;

        assertEq(balanceAfter, balanceBefore + fees, "PunksBids should have earned the right amount of fees");
    }

    function testShouldHaveEarnedLocalFees() public {
        // Local sale
        seller = _offerPunkForSale(punkIndex, defaultPunkPrice, true);

        uint256 finalPrice = punksBids.getFinalPrice(defaultPunkPrice, true);
        uint256 fees = finalPrice - defaultPunkPrice;

        uint256 balanceBefore = address(punksBids).balance;
        punksBids.executeMatch(input, punkIndex);
        uint256 balanceAfter = address(punksBids).balance;

        assertEq(balanceAfter, balanceBefore + fees, "PunksBids should have earned the right amount of local fees");
    }

    function testEmitBidMatched() public {
        uint256 finalPrice = punksBids.getFinalPrice(defaultPunkPrice, false);
        vm.expectEmit(false, false, false, true);
        emit BidMatched(bid.bidder, seller, bid, finalPrice, bidHash);
        punksBids.executeMatch(input, punkIndex);
    }
    
}
