// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/PunksBids.sol";

contract TestPunksBids is PunksBids {
    uint256 private constant INVERSE_BASIS_POINT = 1_000;

    function validateBidParameters(Bid calldata bid, bytes32 bidHash) public view returns (bool) {
        return _validateBidParameters(bid, bidHash);
    }

    function validateSignature(Input calldata bid, bytes32 bidHash) public view returns (bool) {
        return _validateSignature(bid, bidHash);
    }

    function canMatchBidAndPunk(Bid calldata bid, uint256 punkIndex)
        public
        view
        returns (uint256 price, uint256 punkPrice, address seller)
    {
        return _canMatchBidAndPunk(bid, punkIndex);
    }

    function canBuyPunk(Bid calldata bid, uint256 punkIndex) public view returns (uint256, uint256, address) {
        return _canBuyPunk(bid, punkIndex);
    }

    function validatePunkIndex(Bid calldata bid, uint16 punkIndex) public pure returns (bool) {
        return _validatePunkIndex(bid, punkIndex);
    }

    function executeWETHTransfer(address bidder, uint256 price) public {
        _executeWETHTransfer(bidder, price);
    }

    function executeBuyPunk(address bidder, uint256 punkIndex, uint256 punkPrice) public {
        _executeBuyPunk(bidder, punkIndex, punkPrice);
    }

    function getAttributesStringToSliceArray(string memory arrayString)
        public
        pure
        returns (StringUtils.Slice[] memory)
    {
        return _getAttributesStringToSliceArray(arrayString);
    }

    function hashDomain(EIP712Domain memory eip712Domain) public pure returns (bytes32) {
        return _hashDomain(eip712Domain);
    }

    function hashBid(Bid memory bid, uint256 nonce) public pure returns (bytes32) {
        return _hashBid(bid, nonce);
    }

    function hashToSign(bytes32 hash) public view returns (bytes32) {
        return _hashToSign(hash);
    }

    // PASHOV QUESTION : Is it safe to use this method for tests ?
    function getFinalPrice(uint256 punkPrice, bool isLocal) public view returns (uint256) {
        uint256 currentFeeRate = isLocal ? localFeeRate : feeRate;
        return INVERSE_BASIS_POINT * punkPrice / (INVERSE_BASIS_POINT - currentFeeRate);
    }
}
