// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ICryptoPunksMarket {
    function buyPunk(uint256 punkIndex) external payable;

    function transferPunk(address to, uint256 punkIndex) external;

    function punkIndexToAddress(uint256 punkIndex)
        external
        view
        returns (address);

    function punksOfferedForSale(uint256 _punkIndex)
        external
        view
        returns (
            bool isForSale,
            uint256 punkIndex,
            address seller,
            uint256 minValue,
            address onlySellTo
        );

    function punkNoLongerForSale(uint punkIndex) external;

    function offerPunkForSale(uint punkIndex, uint minSalePriceInWei) external;

    function offerPunkForSaleToAddress(uint punkIndex, uint minSalePriceInWei, address toAddress) external;
}