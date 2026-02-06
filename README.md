# 📦 EVM Serialization Primitives: Deterministic State Encoding

![Solidity](https://img.shields.io/badge/Solidity-0.8.24-363636?style=flat-square&logo=solidity)
![Gas Optimization](https://img.shields.io/badge/Gas_Optimization-High-green?style=flat-square)
![Testing](https://img.shields.io/badge/Testing-Foundry-bf4904?style=flat-square)

A set of architectural primitives for **Deterministic Unique Identifier (UID) Generation** and optimized data packing on the EVM. This repository implements the canonical sorting and hashing patterns used by protocols like Uniswap V3 to enable stateless architecture.

## ⚡ Technical Context

In high-performance DeFi protocols, relying on storage (`SSTORE`/`SLOAD`) to maintain registries of asset pairs or order IDs is prohibitively expensive and creates state bloat.

The industry standard solution is **Deterministic Computation**: deriving identifiers mathematically from the immutable properties of the assets themselves. This approach allows contracts to verify the existence and validity of a resource (like a Liquidity Pool) purely through hashing, achieving **O(1)** complexity without storage lookups.

This repository benchmarks and implements these serialization patterns, focusing on the trade-offs between `abi.encode` (standard padding) and `abi.encodePacked` (compressed serialization).

## 🏗 Architecture & Design Patterns

### 1. Canonical Sorting (Invariant Ordering)
* **The Problem:** `Pool(TokenA, TokenB)` and `Pool(TokenB, TokenA)` are logically identical but would generate different hashes if naively encoded.
* **The Solution:** Implemented a lightweight sorting algorithm (`token0 < token1`) before serialization.
* **Outcome:** Ensures collision-resistant, order-independent IDs. This is critical for **CREATE2** address prediction and off-chain indexing.

### 2. Tight Variable Packing (Gas Optimization)
* **Mechanism:** Utilizes `abi.encodePacked` to strip 32-byte padding from data structures.
* **Use Case:** Optimized for generating payloads for **EIP-712** signatures or creating compact keys for nested mappings.
* **Benchmark:** Demonstrates significant calldata reduction compared to standard ABI encoding, essential for L2 rollups where calldata cost is the bottleneck.

### 3. Collision Resistance
* **Security:** Structured the data inputs to prevent "Hash Collision" attacks common in dynamic type packing. By enforcing strict type lengths (address, uint24) within the packed stream, the protocol mitigates ambiguity attacks.

## 🛠 Tech Stack

* **Language:** Solidity `0.8.24`
* **Framework:** Foundry (Forge) for fuzzing and differential testing.
* **Primitives:** `keccak256`, `abi.encodePacked`, Assembly (Low-level optimization).

## 📝 Usage Interface

The library exposes primitives for deterministic generation:

```solidity
/**
 * @notice Generates a deterministic Pool ID using Canonical Sorting.
 * @dev Replicates the computing logic of Uniswap V3 Factory.
 */
function createPoolIdentifier(
    address tokenA, 
    address tokenB, 
    uint24 fee
) external returns (bytes32 poolId);

/**
 * @notice Creates a compact byte-stream for off-chain signing or trailing stops.
 */
function encodeTrailingStopOrder(
    address user,
    address token,
    uint256 amount,
    uint256 trailingPercent,
    uint256 activationPrice
) external returns (bytes memory packedData);
```

## 🧪 Testing Strategy

* **Invariant Testing:** Fuzz tests ensure that `createPoolIdentifier(A, B)` always equals `createPoolIdentifier(B, A)` for random address permutations.
* **Differential Testing:** Compares packed output against standard encoding to verify byte-alignment.

---

*This codebase is maintained for research into EVM low-level serialization techniques.*
