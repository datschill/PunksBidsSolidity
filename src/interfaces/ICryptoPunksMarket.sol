// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ICryptoPunksMarket {
    /**
     * @dev Buy a Punk for sale
     * @param punkIndex Punk Index
     */
    function buyPunk(uint256 punkIndex) external payable;

    /**
     * @dev Transfer a Punk to another wallet
     * @param to recipient address
     * @param punkIndex Punk Index
     */
    function transferPunk(address to, uint256 punkIndex) external;

    /**
     * @dev Retrieve owner address of a Punk
     * @param punkIndex Punk Index
     */
    function punkIndexToAddress(uint256 punkIndex)
        external
        view
        returns (address);

    /**
     * @dev Retrieve Punk sale details
     * @param _punkIndex Punk Index
     */
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

    // Only used in tests
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