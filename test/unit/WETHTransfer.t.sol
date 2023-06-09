// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../Base.t.sol";

contract WETHTransfer is Base {

    uint256 public wethBalance;

    function setUp() public {
        wethBalance = address(weth).balance;

        deal(weth, coco, wethBalance);
        vm.prank(coco);
        IWETH(weth).approve(address(punksBids), wethBalance);
    }

    // _executeWETHTransfer
    function testWETHAreWithdrawnFromBidderAndUnwrapedToPunksBids(uint256 amount) public {
        vm.assume(amount <= wethBalance);

        uint256 balanceBefore = IWETH(weth).balanceOf(coco);
        uint256 balanceBeforePB = address(punksBids).balance;
        punksBids.executeWETHTransfer(coco, amount);
        uint256 balanceAfter = IWETH(weth).balanceOf(coco);
        uint256 balanceAfterPB = address(punksBids).balance;
        
        assertEq(balanceAfter, balanceBefore - amount, "WETH should have been withdrawn from bidder");
        assertEq(balanceAfterPB, balanceBeforePB + amount, "WETH should have been unwrapped and sent to PunksBids");
    }

}


