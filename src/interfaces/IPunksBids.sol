// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Input, Bid } from "../lib/BidStructs.sol";

interface IPunksBids {
    function nonces(address) external view returns (uint256);

    function close() external;

    function cancelBid(Bid calldata bid) external;

    function cancelBids(Bid[] calldata bids) external;

    function incrementNonce() external;

    function executeMatch(Input calldata buy, uint256 punkIndex)
        external;
}
