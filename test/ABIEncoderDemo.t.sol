//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/AbiEncoderDemo.sol";

contract ABIEncoderDemoTest is Test {
    ABIEncoderDemo public abiEncoderDemo;

    function setUp() public {
        abiEncoderDemo = new ABIEncoderDemo();
    }

    function testCreatePoolIdentifier() public {
        address tokenA = address(0x1);
        address tokenB = address(0x2);
        uint24 fee = 3000;

        bytes32 poolId = abiEncoderDemo.createPoolIdentifier(tokenA, tokenB, fee);

        bytes32 expectedPoolId = keccak256(abi.encodePacked(tokenA, tokenB, fee));

        assertEq(poolId, expectedPoolId);
    }
}