// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./lib/EIP712.sol";
import "./lib/StringUtils.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IPunksBids.sol";
import "./interfaces/ICryptoPunksMarket.sol";
import "./interfaces/ICryptoPunksData.sol";

import { Input, Bid } from "./lib/BidStructs.sol";

/**
* @title PunksBids
* @author 0xd0s.eth
* @notice Allows bidding with WETH on specific CryptoPunks or attributes
* @dev Lot of lines of code were taken from the Blur Marketplace, as a source of trust and good architecture example
*/
contract PunksBids is IPunksBids, EIP712, ReentrancyGuard, Ownable {
    using SafeERC20 for IWETH;
    using StringUtils for *;

    /* Auth */
    uint256 public isOpen;

    modifier whenOpen() {
        require(isOpen == 1, "Closed");
        _;
    }

    event Opened();
    event Closed();

    function open() external onlyOwner {
        isOpen = 1;
        emit Opened();
    }
    function close() external onlyOwner {
        isOpen = 0;
        emit Closed();
    }

    /* Constants */
    string public constant NAME = "PunksBids";
    string public constant VERSION = "1.0";
    uint256 public constant INVERSE_BASIS_POINT = 1_000; // Fees
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant CRYPTOPUNKS_MARKETPLACE = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;
    address public constant CRYPTOPUNKS_DATA = 0x16F5A35647D6F03D5D3da7b35409D65ba03aF3B2;

    /* Storage */
    mapping(bytes32 => bool) public cancelledOrFilled;
    mapping(address => uint256) public nonces;

    /**
     * @dev feeRate is applied when a Punk wasn't directly offered to PunksBids
     * @dev localFeeRate is applied when a Punk was directly offered to PunksBids
     */
    uint16 public feeRate = 10;
    uint16 public localFeeRate = 5;

    /* Events */
    event BidMatched(
        address indexed maker,
        address indexed taker,
        Bid bid,
        uint256 price,
        bytes32 bidHash
    );

    event BidCancelled(bytes32 hash);
    event NonceIncremented(address indexed bidder, uint256 newNonce);
    event FeesWithdrawn(address indexed recipient, uint256 amount);
    event FeeRateUpdated(uint16 feeRate);
    event LocalFeeRateUpdated(uint16 localFeeRate);

    /* Errors */
    error BuyPunkFailed(uint256 punkIndex);
    error TransferPunkFailed(uint256 punkIndex);
    error PunkNotSelected(uint256 punkIndex);
    error PunkExcluded(uint256 punkIndex);

    constructor() {
        isOpen = 1;

        DOMAIN_SEPARATOR = _hashDomain(EIP712Domain({
            name              : NAME,
            version           : VERSION,
            chainId           : block.chainid,
            verifyingContract : address(this)
        }));
    }

    receive() external payable {}
    fallback() external payable {}

    /**
     * @dev Match a Bid with a Punk offered for sale, ensuring validity of the match, and execute all associated state transitions.
     * @param buy Buy input
     * @param punkIndex Index of the Punk to be buy on the CryptoPunks Marketplace
     */
    function executeMatch(Input calldata buy, uint256 punkIndex)
        external
        whenOpen
        nonReentrant
    {
        bytes32 bidHash = _hashBid(buy.bid, nonces[buy.bid.bidder]);

        require(_validateBidParameters(buy.bid, bidHash), "Buy has invalid parameters");

        require(_validateSignature(buy, bidHash), "Buy failed authorization");

        (uint256 price, uint256 punkPrice, address seller) = _canMatchBidAndPunk(buy.bid, punkIndex);

        /* Mark bid as filled. */
        cancelledOrFilled[bidHash] = true;

        _executeWETHTransfer(buy.bid.bidder, price);

        _executeBuyPunk(buy.bid.bidder, punkIndex, punkPrice);

        emit BidMatched(
            buy.bid.bidder,
            seller,
            buy.bid,
            price,
            bidHash
        );
    }

    /**
     * @dev Cancel a bid, preventing it from being matched. Must be called by the bidder
     * @param bid Bid to cancel
     */
    function cancelBid(Bid calldata bid) public {
        /* Assert sender is authorized to cancel order. */
        require(msg.sender == bid.bidder, "Not sent by bidder");

        bytes32 hash = _hashBid(bid, nonces[bid.bidder]);

        require(!cancelledOrFilled[hash], "Bid cancelled or filled");

        /* Mark bid as cancelled, preventing it from being matched. */
        cancelledOrFilled[hash] = true;
        emit BidCancelled(hash);
    }

    /**
     * @dev Cancel multiple bids
     * @param bids Bids to cancel
     */
    function cancelBids(Bid[] calldata bids) external {
        for (uint8 i = 0; i < bids.length; i++) {
            cancelBid(bids[i]);
        }
    }

    /**
     * @dev Cancel all current bids for a user, preventing them from being matched. Must be called by the bidder
     */
    function incrementNonce() external {
        nonces[msg.sender] += 1;
        emit NonceIncremented(msg.sender, nonces[msg.sender]);
    }

    /**
     * @dev Sets a new fee rate
     * @param _feeRate The new fee rate
     */
     function setFeeRate(uint16 _feeRate) public onlyOwner {
        feeRate = _feeRate;

        emit FeeRateUpdated(feeRate);
    }

    /**
     * @dev Sets a new local fee rate
     * @param _localFeeRate The new fee rate
     */
     function setLocalFeeRate(uint16 _localFeeRate) public onlyOwner {
        localFeeRate = _localFeeRate;

        emit LocalFeeRateUpdated(localFeeRate);
    }

    /**
     * @dev Withdraw accumulated ETH fees
     * @param recipient The recipient of the fees
     */
    function withdrawFees(address recipient) external onlyOwner {
        require(recipient != address(0), "Transfer to zero address");
        uint256 amount = address(this).balance;
        (bool success,) = payable(recipient).call{value: amount}("");
        require(success, "ETH transfer failed");

        emit FeesWithdrawn(recipient, amount);
    }

    /* Internal Functions */

    /**
     * @dev Verify the validity of the bid parameters
     * @param bid Bid
     * @param bidHash Hash of bid
     */
    function _validateBidParameters(Bid calldata bid, bytes32 bidHash)
        internal
        view
        returns (bool)
    {
        return (
            /* Bid must have a bidder. */
            (bid.bidder != address(0)) &&
            /* Bid must not be cancelled or filled. */
            (!cancelledOrFilled[bidHash]) &&
            /* Bid must be settleable. */
            (bid.listingTime < block.timestamp) &&
            (block.timestamp < bid.expirationTime)
        );
    }

    /**
     * @dev Verify the validity of the signature
     * @param bid Bid
     * @param bidHash Hash of bid
     */
    function _validateSignature(Input calldata bid, bytes32 bidHash)
        internal
        view
        returns (bool)
    {

        if (bid.bid.bidder == msg.sender) {
          return true;
        }

        /* Check user authorization. */
        if (
            !_validateUserAuthorization(
                bidHash,
                bid.bid.bidder,
                bid.v,
                bid.r,
                bid.s
            )
        ) {
            return false;
        }

        return true;
    }

    /**
     * @dev Verify the validity of the user signature
     * @param bidHash Hash of the Bid
     * @param bidder Bidder who should be the signer
     * @param v v
     * @param r r
     * @param s s
     */
    function _validateUserAuthorization(
        bytes32 bidHash,
        address bidder,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool) {
        bytes32 hashToSign = _hashToSign(bidHash);
        // PASHOV QUESTION : Should I use OZ ECDSA instead ? (return ECDSA.recover(bidHash, signature) == signer;)
        return _verify(bidder, hashToSign, v, r, s);
    }

    /**
     * @dev Verify ECDSA signature
     * @param signer Expected signer
     * @param digest Signature preimage
     * @param v v
     * @param r r
     * @param s s
     */
    function _verify(
        address signer,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        require(v == 27 || v == 28, "Invalid v parameter");
        address recoveredSigner = ecrecover(digest, v, r, s);
        if (recoveredSigner == address(0)) {
          return false;
        } else {
          return signer == recoveredSigner;
        }
    }

    /**
     * @dev Checks that the Punk and the Bid can be matched and get sale parameters
     * @param bid Bid
     * @param punkIndex Punk index
     */
    function _canMatchBidAndPunk(Bid calldata bid, uint256 punkIndex)
        internal
        view
        returns (uint256 price, uint256 punkPrice, address seller)
    {
        (price, punkPrice, seller) = _canBuyPunk(bid, punkIndex);

        require(_validatePunkIndex(bid, uint16(punkIndex)), "Invalid Punk index");

        /* Retrieve Punk attributes */
        string memory punkAttributesString = ICryptoPunksData(CRYPTOPUNKS_DATA).punkAttributes(uint16(punkIndex));
        StringUtils.slice[] memory punkAttributes = _getAttributesStringToSliceArray(punkAttributesString, ", ");

        /* Checks Punk base type. */
        if (bytes(bid.baseType).length > 0) {
            StringUtils.slice memory punkBaseType = punkAttributes[0];
            require(punkBaseType.contains(bid.baseType.toSlice()), "Invalid Punk base type");
        }

        /* Checks attributes count. */
        if (bid.attributesCountEnabled) {
            /* -1 to take account of base type. */
            require(punkAttributes.length - 1 == bid.attributesCount, "Invalid attributes count");
        }
        
        /* Compare Bid attributes with Punk attributes. */
        if (bytes(bid.attributes).length > 0) {
            StringUtils.slice memory currentBidAttribute = ''.toSlice();
            StringUtils.slice memory currentPunkAttribute = ''.toSlice();
            StringUtils.slice[] memory bidAttributes = _getAttributesStringToSliceArray(bid.attributes, ", ");
            uint8 attributeOffset = 1; // We skip base type

            for (uint8 i; i<bidAttributes.length; i++) {
                bool hasAttribute = false;
                currentBidAttribute = bidAttributes[i];

                for (uint8 j=attributeOffset; j<punkAttributes.length; j++) {
                    currentPunkAttribute = punkAttributes[j];
                    if (currentBidAttribute.equals(currentPunkAttribute)) {
                        hasAttribute = true;
                        attributeOffset = j+1;
                        break;
                    }
                }

                // PASHOV QUESTION : Remove attributeOffset ? More gas efficient -> but can lead to errors (non matching) if bids aren't properly sorted offchain

                require(hasAttribute, "Mandatory attribute missing");
            }
        }

        return (price, punkPrice, seller);
    }

    /**
     * @dev Checks that the Punk can be bought and get sale parameters
     * @param bid Bid
     * @param punkIndex Punk index
     */
    function _canBuyPunk(Bid calldata bid, uint256 punkIndex)
        internal
        view
        returns (uint256, uint256, address)
    {
        ( 
            bool isForSale,
            ,
            address seller,
            uint256 punkPrice,
            address onlySellTo
        ) = ICryptoPunksMarket(CRYPTOPUNKS_MARKETPLACE).punksOfferedForSale(punkIndex);

        require(isForSale, "Punk not for sale");
        require(onlySellTo == address(0) || onlySellTo == address(this), "Not allowed to buy this Punk");

        uint16 currentFeeRate = onlySellTo == address(this) ? localFeeRate : feeRate;
        uint256 price = INVERSE_BASIS_POINT * punkPrice / (INVERSE_BASIS_POINT - currentFeeRate);

        require(price <= bid.amount, "Insufficient Bid amount");

        return (price, punkPrice, seller);
    }

    /**
     * @dev Verify the validity of the Punk index
     * @param bid Bid
     * @param punkIndex Punk index
     */
    function _validatePunkIndex(Bid calldata bid, uint16 punkIndex)
        internal
        pure
        returns (bool)
    {
        /* If there is an index list, only checks that punkIndex is in this list. */
        if (bid.indexes.length > 0) {
            for (uint i=0; i < bid.indexes.length; i++) {
                if (punkIndex == bid.indexes[i]) {
                    return true;
                }
            }
            revert PunkNotSelected({punkIndex: punkIndex});
        }

        if (bid.excludedIndexes.length > 0) {
            for (uint i=0; i < bid.excludedIndexes.length; i++) {
                if (punkIndex == bid.excludedIndexes[i]) {
                    revert PunkExcluded({punkIndex: punkIndex});
                }
            }
        }

        return (
            (bid.maxIndex == 0 || punkIndex <= bid.maxIndex) &&
            (bid.modulo == 0 || punkIndex % bid.modulo == 0)
        );
    }

    /**
     * @dev Execute WETH transfer and withdraw for ETH
     * @param bidder Bidder
     * @param price Price to be paid by the bidder
     */
    function _executeWETHTransfer(address bidder, uint256 price)
        internal
    {
        /* Retrieve WETH from bidder. */
        IWETH(WETH).safeTransferFrom(bidder, address(this), price);

        /* WETH -> ETH. */
        IWETH(WETH).withdraw(price);
    }

    /**
     * @dev Execute Buy of the Punk
     * @param bidder Bidder
     * @param punkIndex Punk index
     * @param punkPrice Punk price
     */
    function _executeBuyPunk(address bidder, uint256 punkIndex, uint256 punkPrice)
        internal
    {
        try ICryptoPunksMarket(CRYPTOPUNKS_MARKETPLACE).buyPunk{value: punkPrice}(punkIndex) {} catch {
            revert BuyPunkFailed({punkIndex: punkIndex});
        }

        try ICryptoPunksMarket(CRYPTOPUNKS_MARKETPLACE).transferPunk(bidder, punkIndex) {} catch {
            revert TransferPunkFailed({punkIndex: punkIndex});
        }

        // PASHOV QUESTION : Handle external calls like this ?
        // (bool result,) = punkContract.call(abi.encodeWithSignature("transferPunk(address,uint256)", _owner, punkIndex));
        // require(result, "TransferPunkFailed");
    }

    /**
     * @dev Split a string to an array of strings.slice
     * @param arrayString Array as a string
     * @param separator The pattern describing where each split should occur
     */
    function _getAttributesStringToSliceArray(string memory arrayString, string memory separator)
        internal
        pure
        returns (StringUtils.slice[] memory)
    {
        StringUtils.slice memory s = arrayString.toSlice();                
        StringUtils.slice memory delim = separator.toSlice();
        StringUtils.slice[] memory parts = new StringUtils.slice[](s.count(delim) + 1);      
        for (uint i = 0; i < parts.length; i++) {                              
           parts[i] = s.split(delim);                    
        }
        return parts;
    }
}
