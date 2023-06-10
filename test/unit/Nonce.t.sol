// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../Base.t.sol";

contract Nonce is Base {
    event NonceIncremented(address indexed bidder, uint256 newNonce);

    // incrementNonce
    function testIncrementNonce() public {
        uint256 nonce = punksBids.nonces(coco);

        vm.prank(coco);
        punksBids.incrementNonce();

        assertEq(punksBids.nonces(coco), nonce + 1, "Should have incremented nonce");
    }

    function testEmitNonceIncremented() public {
        uint256 nonce = punksBids.nonces(coco);

        vm.startPrank(coco);
        vm.expectEmit(false, false, false, true);
        emit NonceIncremented(coco, nonce + 1);
        punksBids.incrementNonce();
        vm.stopPrank();
    }
}


