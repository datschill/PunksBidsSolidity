// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../Base.t.sol";

contract BuyPunk is Base {

    function setUp() public {
        deal(address(punksBids), defaultPunkPrice);
    }

    function _offerPunkForSale(uint256 punkIndex, uint256 price) internal returns (address seller) {
        seller = punksMarketPlace.punkIndexToAddress(punkIndex);
        vm.prank(seller);
        punksMarketPlace.offerPunkForSale(punkIndex, price);
    }

    // PASHOV QUESTION : Fuzzing : How can I speed tests ?
    // _executeBuyPunk
    function testPunkIsBoughtAndTransferredToBidder(uint256 punkIndex) public {
        vm.assume(punkIndex <= 9999);

        _offerPunkForSale(punkIndex, defaultPunkPrice);

        uint256 balanceBeforePB = address(punksBids).balance;
        punksBids.executeBuyPunk(coco, punkIndex, defaultPunkPrice);
        uint256 balanceAfterPB = address(punksBids).balance;
        address newPunkOwner = punksMarketPlace.punkIndexToAddress(punkIndex);

        assertEq(newPunkOwner, coco, "Bidder should be the new owner of the Punk");
        assertEq(balanceAfterPB, balanceBeforePB - defaultPunkPrice, "PunksBids should have paid exactly defaultPunkPrice in ETH");
    }

    function testCannotBuyPunkIfPricePaidIsTooLow(uint256 punkIndex) public {
        vm.assume(punkIndex <= 9999);

        _offerPunkForSale(punkIndex, defaultPunkPrice);

        vm.expectRevert(
            abi.encodeWithSelector(BuyPunkFailed.selector, punkIndex)
        );
        punksBids.executeBuyPunk(coco, punkIndex, defaultPunkPrice - 1);
    }

}


