// SPDX-License-Identifier: GPL-V3
pragma solidity ^0.8.0;

import { UintUtils } from '@solidstate/contracts/utils/UintUtils.sol';
import { ERC721MetadataInternal } from '@solidstate/contracts/token/ERC721/metadata/ERC721MetadataInternal.sol';
import { ERC721AttributesStorage } from './ERC721AttributesStorage.sol';
import { IERC721AttributesInternal } from './IERC721AttributesInternal.sol';

/**
 * @title ERC721Attributes internal functions
 */
abstract contract ERC721AttributesInternal is IERC721AttributesInternal, ERC721MetadataInternal {
    using UintUtils for uint256;

    /**
     * @notice get generated URI for given token
     * @return token URI
     */
    function _tokenURI(uint256 tokenId) internal view virtual override(ERC721MetadataInternal) returns (string memory) {
        if (!_exists(tokenId)) revert ERC721Attributes__NonExistentToken();

        ERC721AttributesStorage.Layout storage l = ERC721AttributesStorage.layout();

       return "";
    }

    function _attributeOf(uint256 tokenId, uint256 id) internal view virtual returns (bytes32) {
        if (!_exists(tokenId)) revert ERC721Attributes__NonExistentToken();
        return ERC721AttributesStorage.layout().attributes[tokenId][id];
    }
}