// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/interfaces/ICryptoPunksMarket.sol";

interface ITestCryptoPunksMarket is ICryptoPunksMarket {
    /**
     * @dev Remove a Punk from sale
     * @param punkIndex Punk Index
     */
    function punkNoLongerForSale(uint punkIndex) external;

    /**
     * @dev Offer a Punk for sale
     * @param punkIndex Punk Index
     * @param minSalePriceInWei Minimum price in wei
     */
    function offerPunkForSale(uint punkIndex, uint minSalePriceInWei) external;

    /**
     * @dev Offer a Punk for sale, to a specific address
     * @param punkIndex Punk Index
     * @param minSalePriceInWei Minimum price in wei
     * @param toAddress The only address allowed to buy the Punk
     */
    function offerPunkForSaleToAddress(uint punkIndex, uint minSalePriceInWei, address toAddress) external;
}