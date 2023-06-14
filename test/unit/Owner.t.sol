// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../Base.t.sol";

contract Fees is Base {
    event Opened();
    event Closed();
    event FeesWithdrawn(address indexed recipient, uint256 amount);
    event FeeRateUpdated(uint256 feeRate);
    event LocalFeeRateUpdated(uint256 localFeeRate);

    function setUp() public {
        // Give Owner 100 ETH
        vm.deal(address(this), 100 ether);
        // Give PunksBids contract 100 ETH
        vm.deal(address(punksBids), 100 ether);
    }

    // open/close
    function testOpen() public {
        vm.expectEmit(false, false, false, true);
        emit Opened();
        punksBids.open();

        assertEq(punksBids.isOpen(), 1, "PunksBids should be open");
    }

    function testClose() public {
        vm.expectEmit(false, false, false, true);
        emit Closed();
        punksBids.close();

        assertEq(punksBids.isOpen(), 0, "PunksBids should be closed");
    }

    // setFeeRate
    function testSetFeeRate(uint256 feeRate) public {
        punksBids.setFeeRate(feeRate);

        assertEq(punksBids.feeRate(), feeRate, "Should have updated feeRate");
    }

    function testCannotSetFeeRate(uint256 feeRate) public {
        vm.prank(coco);
        vm.expectRevert("Ownable: caller is not the owner");
        punksBids.setFeeRate(feeRate);
    }

    function testEmitFeeRateUpdated(uint256 feeRate) public {
        vm.expectEmit(false, false, false, true);
        emit FeeRateUpdated(feeRate);
        punksBids.setFeeRate(feeRate);
    }

    // setLocalFeeRate
    function testSetLocalFeeRate(uint256 locaFeeRate) public {
        punksBids.setLocalFeeRate(locaFeeRate);

        assertEq(punksBids.localFeeRate(), locaFeeRate, "Should have updated localFeeRate");
    }

    function testCannotSetLocalFeeRate(uint256 locaFeeRate) public {
        vm.prank(coco);
        vm.expectRevert("Ownable: caller is not the owner");
        punksBids.setLocalFeeRate(locaFeeRate);
    }

    function testEmitLocalFeeRateUpdated(uint256 locaFeeRate) public {
        vm.expectEmit(false, false, false, true);
        emit LocalFeeRateUpdated(locaFeeRate);
        punksBids.setLocalFeeRate(locaFeeRate);
    }

    // withdrawFees
    function testCannotWithdrawToNonPayableAddress() public {
        vm.expectRevert(abi.encodeWithSelector(ETHTransferFailed.selector, address(revertFallback)));
        punksBids.withdrawFees(address(revertFallback));
    }

    function testCannotWithdrawFees() public {
        vm.prank(coco);
        vm.expectRevert("Ownable: caller is not the owner");
        punksBids.withdrawFees(dada);
    }

    function testWithdrawFullBalance() public {
        uint256 balanceDada = address(dada).balance;
        uint256 balancePunksBids = address(punksBids).balance;

        punksBids.withdrawFees(dada);

        uint256 balanceDadaAfter = address(dada).balance;
        uint256 balancePunksBidsAfter = address(punksBids).balance;

        assertEq(balancePunksBidsAfter, 0, "Should have sent full balance of PunksBids");
        assertEq(balanceDadaAfter, balanceDada + balancePunksBids, "Should have sent punksBids balance to 0xdada");
    }

    function testEmitFeesWithdrawn() public {
        uint256 balancePunksBids = address(punksBids).balance;
        vm.expectEmit(false, false, false, true);
        emit FeesWithdrawn(dada, balancePunksBids);
        punksBids.withdrawFees(dada);
    }

    // Fallback
    function testCannotSendETH(uint256 amount) public {
        vm.expectRevert(NotPayable.selector);
        payable(revertFallback).call{value: amount}("PunksBids");
    }
}
