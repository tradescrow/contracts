// SPDX-License-Identifier: GPL-V3
pragma solidity ^0.8.0;

import { ERC165Base } from '@solidstate/contracts/introspection/ERC165/base/ERC165Base.sol';
import { ERC721Base, ERC721BaseInternal } from '@solidstate/contracts/token/ERC721/base/ERC721Base.sol';
import { ERC721Enumerable } from '@solidstate/contracts/token/ERC721/enumerable/ERC721Enumerable.sol';
import { ISolidStateERC721 } from '@solidstate/contracts/token/ERC721/ISolidStateERC721.sol';

import { TradescrowProfileMetadata } from './TradescrowProfileMetadata.sol';

/**
 * @title SolidState ERC721 implementation, including recommended extensions
 */
contract TradescrowProfile is
    ISolidStateERC721,
    ERC721Base,
    ERC721Enumerable,
    TradescrowProfileMetadata,
    ERC165Base
{
    error TradescrowProfile__NonTransferableNFT();

    /**
     * @notice ERC721 hook: revert if value is included in external approve function call
     * @inheritdoc ERC721BaseInternal
     */
    function _handleApproveMessageValue(
        address operator,
        uint256 tokenId,
        uint256 value
    ) internal virtual override {
        if (value > 0) revert SolidStateERC721__PayableApproveNotSupported();
        super._handleApproveMessageValue(operator, tokenId, value);
    }

    /**
     * @notice ERC721 hook: revert if value is included in external transfer function call
     * @inheritdoc ERC721BaseInternal
     */
    function _handleTransferMessageValue(
        address from,
        address to,
        uint256 tokenId,
        uint256 value
    ) internal virtual override {
        if (value > 0) revert SolidStateERC721__PayableTransferNotSupported();
        super._handleTransferMessageValue(from, to, tokenId, value);
    }

    /**
     * @inheritdoc ERC721BaseInternal
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721BaseInternal, TradescrowProfileMetadata) {
        super._beforeTokenTransfer(from, to, tokenId);
        revert TradescrowProfile__NonTransferableNFT();
    }
}