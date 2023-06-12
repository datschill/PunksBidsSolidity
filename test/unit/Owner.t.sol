// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../Base.t.sol";

contract Fees is Base {
    event Opened();
    event Closed();
    event FeesWithdrawn(address indexed recipient, uint256 amount);
    event FeeRateUpdated(uint16 feeRate);
    event LocalFeeRateUpdated(uint16 localFeeRate);

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
    function testSetFeeRate() public {
        punksBids.setFeeRate(20);

        assertEq(punksBids.feeRate(), 20, "Should have updated feeRate");
    }

    function testCannotSetFeeRate() public {
        vm.prank(coco);
        vm.expectRevert("Ownable: caller is not the owner");
        punksBids.setFeeRate(20);
    }

    function testEmitFeeRateUpdated() public {
        vm.expectEmit(false, false, false, true);
        emit FeeRateUpdated(20);
        punksBids.setFeeRate(20);
    }
    
    // setLocalFeeRate
    function testSetLocalFeeRate() public {
        punksBids.setLocalFeeRate(20);

        assertEq(punksBids.localFeeRate(), 20, "Should have updated localFeeRate");
    }

    function testCannotSetLocalFeeRate() public {
        vm.prank(coco);
        vm.expectRevert("Ownable: caller is not the owner");
        punksBids.setLocalFeeRate(20);
    }

    function testEmitLocalFeeRateUpdated() public {
        vm.expectEmit(false, false, false, true);
        emit LocalFeeRateUpdated(20);
        punksBids.setLocalFeeRate(20);
    }

    // withdrawFees
    function testCannotWithdrawToNullAddress() public {
        vm.expectRevert(TransferToZeroAddress.selector);
        punksBids.withdrawFees(address(0));
    }

    function testCannotWithdrawToNonPayableAddress() public {
        vm.expectRevert(
            abi.encodeWithSelector(ETHTransferFailed.selector, address(revertFallback))
        );
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
}


