// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../Base.t.sol";

contract CanMatchBidAndPunk is Base {
    uint256 public notForSalePunkIndex = 666;
    address public notForSalePunkAddress;
    uint256 public forSalePunkIndex = 888;
    address public forSalePunkAddress;
    uint256 public zombiePunkIndex = 1190;
    address public zombieForSalePunkAddress;
    uint256 public alienPunkIndex = 3100;
    address public alienForSalePunkAddress;
    uint256 public threeAttributesPunkIndex = 3;
    address public threeAttributesForSalePunkAddress;

    uint256 public uniquePunkIndex = 4338;
    address public uniquePunkAddress;
    string public uniquePunkAttributes = "Cap Forward, Nerd Glasses, Clown Nose";

    uint256 public apePunkIndex = 372;
    uint256 public malePunkIndex = 3;

    string[] public baseTypes = ["Male", "Female", "Zombie", "Ape", "Alien"];

    uint256 public defaultPunkPrice = 0xffffffffff;

    ICryptoPunksMarket public punksMarketPlace;

    Bid public bid;

    function setUp() public {
        bid = defaultBid();

        punksMarketPlace = ICryptoPunksMarket(punksBids.CRYPTOPUNKS_MARKETPLACE());

        // Init Punk not for sale
        notForSalePunkAddress = punksMarketPlace.punkIndexToAddress(notForSalePunkIndex);
        vm.prank(notForSalePunkAddress);
        punksMarketPlace.punkNoLongerForSale(notForSalePunkIndex);

        // Init punk for sale
        forSalePunkAddress = _offerPunkForSale(forSalePunkIndex);

        // Init zombie punk for sale
        zombieForSalePunkAddress = _offerPunkForSale(zombiePunkIndex);

        // Init alien punk for sale
        alienForSalePunkAddress = _offerPunkForSale(alienPunkIndex);

        // Init 3 attributes punk for sale
        threeAttributesForSalePunkAddress = _offerPunkForSale(threeAttributesPunkIndex);

        // Init Unique Punk for sale
        uniquePunkAddress = _offerPunkForSale(uniquePunkIndex);
    }

    function _offerPunkForSale(uint256 punkIndex) internal returns (address seller) {
        seller = punksMarketPlace.punkIndexToAddress(punkIndex);
        vm.prank(seller);
        punksMarketPlace.offerPunkForSale(punkIndex, defaultPunkPrice);
    }

    function _canBuyPunk(Bid memory _bid, uint256 _punkIndex) internal {
        ( 
            ,
            ,
            address pSeller,
            uint256 pPrice,
            address onlySellTo
        ) = punksMarketPlace.punksOfferedForSale(_punkIndex);

        bool isLocal = onlySellTo == address(punksBids);

        uint256 finalPrice = punksBids.getFinalPrice(pPrice, isLocal);

        (uint256 price, uint256 punkPrice, address seller) = punksBids.canBuyPunk(_bid, _punkIndex);

        assertEq(finalPrice, price, "price should be equal to finalPrice");
        assertEq(pPrice, punkPrice, "punkPrice should be equal to retrieved Punk price");
        assertEq(pSeller, seller, "seller should be equal to retrieved seller");
    }
    
    function _canMatchBidAndPunk(Bid memory _bid, uint256 _punkIndex) internal {
        ( 
            ,
            ,
            address pSeller,
            uint256 pPrice,
            address onlySellTo
        ) = punksMarketPlace.punksOfferedForSale(_punkIndex);

        bool isLocal = onlySellTo == address(punksBids);

        uint256 finalPrice = punksBids.getFinalPrice(pPrice, isLocal);

        (uint256 price, uint256 punkPrice, address seller) = punksBids.canMatchBidAndPunk(_bid, _punkIndex);

        assertEq(finalPrice, price, "price should be equal to finalPrice");
        assertEq(pPrice, punkPrice, "punkPrice should be equal to retrieved Punk price");
        assertEq(pSeller, seller, "seller should be equal to retrieved seller");
    }

    // _canMatchBidAndPunk
    // _canBuyPunk
    function testCanBuyPunk() public {
        _canBuyPunk(bid, forSalePunkIndex);
    }

    function testCannotBuyPunkNotForSale() public {
        vm.expectRevert(
            abi.encodeWithSelector(PunkNotForSale.selector, notForSalePunkIndex)
        );
        punksBids.canBuyPunk(bid, notForSalePunkIndex);
    }

    function testCannotBuyPunkNotForSalePublic() public {
        // Offer Punk for sale to 0xdada
        vm.prank(forSalePunkAddress);
        punksMarketPlace.offerPunkForSaleToAddress(forSalePunkIndex, defaultPunkPrice, dada);

        vm.expectRevert(
            abi.encodeWithSelector(PunkNotGloballyForSale.selector, forSalePunkIndex, dada)
        );
        punksBids.canBuyPunk(bid, forSalePunkIndex);
    }

    function testCannotSetBidAmountTooLow(uint256 bidAmount) public {
        bidAmount = bound(bidAmount, 1, defaultPunkPrice);

        uint256 finalPrice = punksBids.getFinalPrice(defaultPunkPrice, false);
        // Bid Amount < finalPrice (don't take account of fees)
        bid.amount = finalPrice - 1;

        vm.expectRevert(
            abi.encodeWithSelector(BidAmountTooLow.selector, finalPrice, bid.amount)
        );
        punksBids.canBuyPunk(bid, forSalePunkIndex);
    }

    //_validatePunkIndex
    function testValidatePunkIfInIndexesList(uint16 punkIndex) public {
        bid.indexes.push(punkIndex);

        assertEq(punksBids.validatePunkIndex(bid, punkIndex), true, "Punk index could be in indexes list");
    }

    function testValidatePunkIfNotInExcludedIndexesList(uint16 punkIndex, uint16 excludedPunkIndex) public {
        vm.assume(punkIndex != excludedPunkIndex);
        bid.excludedIndexes.push(excludedPunkIndex);

        assertEq(punksBids.validatePunkIndex(bid, punkIndex), true, "Punk index is valid if not excluded");
    }

    function testCannotBuyPunkIfIndexNotInIndexesList(uint16 punkIndex, uint16 selectedPunkIndex) public {
        bid.indexes.push(selectedPunkIndex);
        vm.assume(punkIndex != selectedPunkIndex);

        vm.expectRevert(
            abi.encodeWithSelector(PunkNotSelected.selector, punkIndex)
        );
        punksBids.validatePunkIndex(bid, punkIndex);
    }

    function testCannotBuyPunkIfIndexIsExcluded(uint16 punkIndex) public {
        bid.excludedIndexes.push(punkIndex);

        vm.expectRevert(
            abi.encodeWithSelector(PunkExcluded.selector, punkIndex)
        );
        punksBids.validatePunkIndex(bid, punkIndex);
    }

    function testCannotBuyPunkIfIndexIsGreaterThanMaxIndex(uint16 punkIndex, uint16 maxIndex) public {
        vm.assume(maxIndex > 0);
        vm.assume(punkIndex > maxIndex);

        bid.maxIndex = maxIndex;

        bool isValidPunkIndex = punksBids.validatePunkIndex(bid, punkIndex);

        assertEq(isValidPunkIndex, false, "Punk index should be lower or equal to maxIndex");
    }

    function testCannotBuyPunkIfIndexDoesntFitWithModulo(uint16 punkIndex, uint16 modulo) public {
        vm.assume(modulo > 0);
        vm.assume(punkIndex % modulo != 0);

        bid.modulo = modulo;

        bool isValidPunkIndex = punksBids.validatePunkIndex(bid, punkIndex);

        assertEq(isValidPunkIndex, false, "Punk index should fit with modulo");
    }

    function testCannotValidatePunkIndex(uint16 punkIndex, uint16 maxIndex) public {
        vm.assume(maxIndex > 0);
        vm.assume(punkIndex > maxIndex);
        vm.assume(punkIndex <= 9999);

        bid.maxIndex = maxIndex;

        _offerPunkForSale(punkIndex);

        vm.expectRevert(
            abi.encodeWithSelector(InvalidPunkIndex.selector, punkIndex)
        );
        punksBids.canMatchBidAndPunk(bid, punkIndex);
    }

    function testCannotMatchBidAndPunkIfBaseTypeDoesntMatch(uint8 baseTypeIndex) public {
        // Not Alien index
        string memory baseType = baseTypes[bound(baseTypeIndex, 0, baseTypes.length - 2)];
        
        bid.baseType = baseType;

        vm.expectRevert(InvalidPunkBaseType.selector);
        punksBids.canMatchBidAndPunk(bid, alienPunkIndex);
    }

    function testCanMatchBidAndPunkIfBaseTypeMatch() public {
        bid.baseType = "Zombie";

        _canMatchBidAndPunk(bid, zombiePunkIndex);
    }

    function testCannotMatchBidAndPunkIfAttributesCountDoesntMatch(uint8 attributesCount) public {
        vm.assume(attributesCount != 3);
        
        bid.attributesCountEnabled = true;
        bid.attributesCount = attributesCount;

        vm.expectRevert(
            abi.encodeWithSelector(InvalidPunkAttributesCount.selector, 3, attributesCount)
        );
        punksBids.canMatchBidAndPunk(bid, threeAttributesPunkIndex);
    }

    function testMatchBidAndPunkIfAttributesCountIsCorrect() public {
        bid.attributesCountEnabled = true;
        bid.attributesCount = 3;

        _canMatchBidAndPunk(bid, threeAttributesPunkIndex);
    }

    function testMatchBidAndPunkIfAttributesCountNotEnabled(uint8 attributesCount) public {
        bid.attributesCount = attributesCount;

        _canMatchBidAndPunk(bid, threeAttributesPunkIndex);
    }

    function testMatchBidAndPunkIfPunkHaveAttributes() public {
        bid.attributes = uniquePunkAttributes;

        _canMatchBidAndPunk(bid, uniquePunkIndex);
    }

    function testCannotMatchBidAndPunkIfPunkDoesntHaveAttributes() public {
        bid.attributes = uniquePunkAttributes;

        vm.expectRevert(PunkMissingAttributes.selector);
        punksBids.canMatchBidAndPunk(bid, alienPunkIndex);
    }

    // TOO SLOW
    // function testCannotMatchBidAndPunkIfPunkDoesntHaveAttributes(uint16 punkIndex) public {
    //     vm.assume(punkIndex <= 9999 && punkIndex != uniquePunkIndex);
    //     bid.attributes = uniquePunkAttributes;

    //     // Offer Punk for sale
    //     address punkAddress = punksMarketPlace.punkIndexToAddress(punkIndex);
    //     vm.prank(punkAddress);
    //     punksMarketPlace.offerPunkForSale(punkIndex, defaultPunkPrice);

    //     vm.expectRevert(PunkMissingAttributes.selector);
    //     punksBids.canMatchBidAndPunk(bid, punkIndex);
    // }
}