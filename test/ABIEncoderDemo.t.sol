//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/ABIEncoderDemo.sol";


/// @title ABIEncoderDemoTest
/// @notice Comprehensive tests suite targeting 100% coverage for ABIEncoderDemo contract
contract ABIEncoderDemoTest is Test {
    ABIEncoderDemo private abiEncoderDemo;

    /// @dev Deploys a fresh contract before each test
    function setUp() public {
        abiEncoderDemo = new ABIEncoderDemo();
    }

    /// @dev Pool id must be invariant to the order of the tokens, tokens are sorted internally
    function test_createPoolIdentifier_SameForBothTokenOrders() external {
        address tokenA = address(0x1000);
        address tokenB = address(0x2000);
        uint24 fee = 3000;

        bytes32 poolId1 = abiEncoderDemo.createPoolIdentifier(tokenA, tokenB, fee);
        bytes32 poolId2 = abiEncoderDemo.createPoolIdentifier(tokenB, tokenA, fee);

        assertEq(poolId1, poolId2, "Pool id must be invariant to the order of the tokens");
    }
    
    function test_createPoolIdentifier_DifferentFeeDifferentPoolId() external {
        address tokenA = address(0x1000);
        address tokenB = address(0x2000);
        uint24 fee1 = 3000;
        uint24 fee2 = 500;

        bytes32 poolId1 = abiEncoderDemo.createPoolIdentifier(tokenA, tokenB, fee1);
        bytes32 poolId2 = abiEncoderDemo.createPoolIdentifier(tokenA, tokenB, fee2);

        assertNotEq(poolId1, poolId2, "Pool id must be different for different fees");
    }

    function test_encodeTradingPosition_ReturnsExpectedDataAndHash() external {
        address user = address(0x1000);
        address tokenIn = address(0x2000);
        address tokenOut = address(0x3000);
        uint256 amountIn = 1 ether;
        uint256 minAmountOut = 2 ether;
        uint256 deadline = block.timestamp + 1 days;

        (bytes32 userPositionId, bytes memory encodedData) = abiEncoderDemo.encodeTradingPosition(user, tokenIn, tokenOut, amountIn, minAmountOut, deadline);


        assertEq(encodedData, abi.encodePacked(user, tokenIn, tokenOut, amountIn, minAmountOut, deadline), "Encoded data must match the expected data");
        assertEq(userPositionId, keccak256(encodedData), "User position id must match the hash of the encoded data");
    }   


    function test_encodeSwapData_EncodesPathAmountDeadline() external {
        address[] memory path = new address[](3);
        path[0] = address(0x1000);
        path[1] = address(0x2000);
        path[2] = address(0x3000);
        uint256[] memory amount = new uint256[](3);
        amount[0] = 1 ether;
        amount[1] = 2 ether;
        amount[2] = 3 ether;
        uint256 deadline = block.timestamp + 1 days;

        bytes memory encodedData = abiEncoderDemo.encodeSwapData(path, amount, deadline);

        bytes memory expectedPathData;
        for(uint i = 0; i < path.length; i++) {
            expectedPathData = abi.encodePacked(expectedPathData, path[i]);
        }
        bytes memory expectedAmountData;
        for(uint i = 0; i < amount.length; i++) {
            expectedAmountData = abi.encodePacked(expectedAmountData, amount[i]);
        }
        bytes memory expectedEncodedData = abi.encodePacked(expectedPathData, expectedAmountData, deadline);

        assertEq(encodedData, expectedEncodedData, "Encoded data must match the expected data");
        assertEq(keccak256(encodedData), keccak256(expectedEncodedData), "Hash must match");
    }

    function test_encodeSwapData_RevertsOnDifferentLengths() external {
        address[] memory path = new address[](3);
        path[0] = address(0x1000);
        path[1] = address(0x2000);
        path[2] = address(0x3000);
        uint256[] memory amount = new uint256[](2);
        amount[0] = 1 ether;
        amount[1] = 2 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.expectRevert(abi.encodeWithSignature("Error(string)", "Array length mismatch"));
        abiEncoderDemo.encodeSwapData(path, amount, deadline);
    }
}