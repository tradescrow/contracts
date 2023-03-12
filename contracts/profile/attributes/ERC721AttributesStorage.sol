// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

library ERC721AttributesStorage {
    bytes32 internal constant STORAGE_SLOT = keccak256('dirtycajunrice.contracts.storage.attributes');

    struct Layout {
        // tokenId => attribute id => attribute value;
        mapping(uint256 => mapping(uint256 => bytes32)) attributes;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

}