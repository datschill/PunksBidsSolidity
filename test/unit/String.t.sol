// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../Base.t.sol";

contract String is Base {
    using StringUtils for *;

    function testAttributesStringToArray() public {
        string memory arrayString = "Alien, Earring, Forward Cap, Cigarette";

        StringUtils.Slice[] memory parts = punksBids.getAttributesStringToSliceArray(arrayString);

        StringUtils.Slice memory alienSlice = "Alien".toSlice();
        StringUtils.Slice memory earringSlice = "Earring".toSlice();
        StringUtils.Slice memory capSlice = "Forward Cap".toSlice();
        StringUtils.Slice memory cigaretteSlice = "Cigarette".toSlice();

        assertEq(parts[0].equals(alienSlice), true, "Check Alien base type");
        assertEq(parts[1].equals(earringSlice), true, "Check Earring attribute");
        assertEq(parts[2].equals(capSlice), true, "Check Forward Cap attribute");
        assertEq(parts[3].equals(cigaretteSlice), true, "Check Cigarette attribute");
    }

    function testEquals(string memory first, string memory second) public {
        assertEq(
            first.toSlice().equals(second.toSlice()),
            keccak256(abi.encodePacked(first)) == keccak256(abi.encodePacked(second)),
            "String comparaison should be the same as keccak256 comparaison"
        );
    }

    function testSplit() public {
        StringUtils.Slice memory arrayString = "Zombie, Cap, 3D Glasses, Vape, Mole".toSlice();

        StringUtils.Slice memory zombieSlice = "Zombie".toSlice();
        StringUtils.Slice memory capSlice = "Cap".toSlice();
        StringUtils.Slice memory glassesSlice = "3D Glasses".toSlice();
        StringUtils.Slice memory vapeSlice = "Vape".toSlice();
        StringUtils.Slice memory moleSlice = "Mole".toSlice();

        StringUtils.Slice[5] memory attributes = [zombieSlice, capSlice, glassesSlice, vapeSlice, moleSlice];

        StringUtils.Slice memory delim = ATTRIBUTES_SEPARATOR.toSlice();

        for (uint256 i; i < attributes.length; i++) {
            assertEq(attributes[i].equals(arrayString.split(delim)), true, "Check that we retrieved attribute");
        }
    }

    function testToSlice(string memory str) public {
        uint256 ptr;
        assembly {
            ptr := add(str, 0x20)
        }
        StringUtils.Slice memory s = StringUtils.Slice(bytes(str).length, ptr);

        // assertEq(StringUtils.toSlice(str)._len, s._len, "_len should be correct");
        // assertEq(StringUtils.toSlice(str)._ptr, s._ptr, "_ptr should be correct");
        assertEq(str.toSlice()._len, s._len, "_len should be correct");
        assertEq(str.toSlice()._ptr, s._ptr, "_ptr should be correct");
    }

    function testCount(string memory str, uint8 occurence) public {
        string memory noise = "delimiter";

        vm.assume(
            occurence != 0 && bytes(str).length != 0
                && (
                    bytes(str).length != bytes(noise).length
                        || keccak256(abi.encodePacked(str)) != keccak256(abi.encodePacked(noise))
                )
        );

        string memory sentence = "";
        for (uint256 i; i < occurence; i++) {
            sentence = string.concat(sentence, noise, str);
        }

        StringUtils.Slice memory sentenceSlice = sentence.toSlice();
        StringUtils.Slice memory strSlice = str.toSlice();
        StringUtils.Slice memory noiseSlice = noise.toSlice();

        uint256 count = sentenceSlice.count(strSlice);
        uint256 countInNoise = noiseSlice.count(strSlice);
        assertEq(count, occurence + (occurence - 1) * countInNoise, "StringUtils.count()");
    }
}
