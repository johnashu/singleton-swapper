// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ops} from "../Ops.sol";

/// @author philogy <https://github.com/philogy>
library EncoderLib {
    function init(uint256 hashMapSize) internal pure returns (bytes memory program) {
        require(hashMapSize <= 0xffff);
        assembly {
            program := mload(0x40)
            mstore(0x40, add(program, 0x22))
            mstore(add(program, 2), hashMapSize)
            mstore(program, 2)
        }
    }

    function appendSwap(bytes memory self, address token0, address token1, bool zeroForOne, uint256 amount)
        internal
        pure
        returns (bytes memory)
    {
        uint256 op = Ops.SWAP;
        assembly {
            let length := mload(self)
            mstore(self, add(length, 58))
            let initialOffset := add(add(self, 0x20), length)

            mstore(initialOffset, shl(248, op))
            mstore(add(initialOffset, 1), shl(96, token0))
            mstore(add(initialOffset, 21), shl(96, token1))
            mstore(add(initialOffset, 41), zeroForOne)
            mstore(add(initialOffset, 42), shl(128, amount))
        }

        return self;
    }

    function appendAddLiquidity(
        bytes memory self,
        address token0,
        address token1,
        address to,
        uint256 maxAmount0,
        uint256 maxAmount1
    ) internal pure returns (bytes memory) {
        uint256 op = Ops.ADD_LIQ;
        assembly {
            let length := mload(self)
            mstore(self, add(length, 93))
            let initialOffset := add(add(self, 0x20), length)

            mstore(initialOffset, shl(248, op))
            mstore(add(initialOffset, 1), shl(96, token0))
            mstore(add(initialOffset, 21), shl(96, token1))
            mstore(add(initialOffset, 41), shl(96, to))
            mstore(add(initialOffset, 61), shl(128, maxAmount0))
            mstore(add(initialOffset, 77), shl(128, maxAmount1))
        }

        return self;
    }

    function appendSend(bytes memory self, address token, address to, uint256 amount)
        internal
        pure
        returns (bytes memory)
    {
        uint256 op = Ops.SEND;
        assembly {
            let length := mload(self)
            mstore(self, add(length, 56))
            let initialOffset := add(add(self, 0x20), length)

            mstore(initialOffset, shl(248, op))
            mstore(add(initialOffset, 1), shl(96, token))
            mstore(add(initialOffset, 21), shl(96, to))
            mstore(add(initialOffset, 41), shl(128, amount))
        }

        return self;
    }

    function done(bytes memory self) internal pure returns (bytes memory) {
        assembly {
            let freeMem := mload(0x40)
            mstore(0x40, add(freeMem, mload(self)))
        }
        return self;
    }
}