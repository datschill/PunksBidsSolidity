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

    function _offerPunkForSale(uint256 _punkIndex, uint256 price, bool isLocal) internal returns (address) {
        address toAddress = isLocal ? address(punksBids) : address(0);
        seller = punksMarketPlace.punkIndexToAddress(_punkIndex);
        vm.prank(seller);
        punksMarketPlace.offerPunkForSaleToAddress(_punkIndex, price, toAddress);
        return seller;
    }

    // open/close
    function testCannotExecuteIfClosed() public {
        punksBids.close();

        vm.expectRevert(PunksBidsClosed.selector);
        punksBids.executeMatch(input, punkIndex);
    }

    // executeMatch
    function testBidIsFlaggedAsFilled() public {
        punksBids.executeMatch(input, punkIndex);

        bool filled = punksBids.cancelledOrFilled(bidHash);

        assertEq(filled, true, "Bid should be flagged as filled");
    }

    function testCannotCancelFilledBid() public {
        punksBids.executeMatch(input, punkIndex);

        vm.startPrank(input.bid.bidder);
        vm.expectRevert(
            abi.encodeWithSelector(BidAlreadyCancelledOrFilled.selector, input.bid)
        );
        punksBids.cancelBid(input.bid);
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

    function testCannotValidateBidParameters() public {
        // Invalid bid parameter
        input.bid.bidder = address(0);

        vm.expectRevert(
            abi.encodeWithSelector(InvalidBidParameters.selector, input.bid)
        );
        punksBids.executeMatch(input, punkIndex);
    }

    function testCannotValidateSignature() public {
        bidHash = punksBids.hashBid(bid, nonce);
        bidHashToSign = punksBids.hashToSign(bidHash);
        // Signer != Bidder
        (uint8 v, bytes32 r, bytes32 s) = signHash(dadaPK, bidHashToSign);

        input = Input({
            bid: bid,
            v: v,
            r: r,
            s: s
        });
        
        vm.expectRevert(
            abi.encodeWithSelector(InvalidSignature.selector, input)
        );
        punksBids.executeMatch(input, punkIndex);
    }

    function testEmitBidMatched() public {
        uint256 finalPrice = punksBids.getFinalPrice(defaultPunkPrice, false);
        vm.expectEmit(false, false, false, true);
        emit BidMatched(bid.bidder, seller, bid, finalPrice, bidHash);
        punksBids.executeMatch(input, punkIndex);
    }
    
}
