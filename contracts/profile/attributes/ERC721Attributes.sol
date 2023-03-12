// SPDX-License-Identifier: GPL-V3
pragma solidity ^0.8.0;

import { IERC721Metadata } from '@solidstate/contracts/token/ERC721/metadata/IERC721Metadata.sol';
import { TradescrowProfileMetadataInternal } from './ERC721AttributesInternal.sol';

/**
 * @title ERC721 metadata extensions
 */
abstract contract ERC721Attributes is IERC721Metadata, TradescrowProfileMetadataInternal {
    /**
     * @notice inheritdoc IERC721Metadata
     */
    function name() external view virtual returns (string memory) {
        return _name();
    }

    /**
     * @notice inheritdoc IERC721Metadata
     */
    function symbol() external view virtual returns (string memory) {
        return _symbol();
    }

    /**
     * @notice inheritdoc IERC721Metadata
     */
    function tokenURI(
        uint256 tokenId
    ) external view virtual returns (string memory) {
        return _tokenURI(tokenId);
    }

    /**
     * @inheritdoc ERC721MetadataInternal
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}