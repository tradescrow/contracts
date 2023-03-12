// SPDX-License-Identifier: GPL-V3
pragma solidity ^0.8.0;

import { ERC721MetadataInternal } from '@solidstate/contracts/token/ERC721/metadata/ERC721MetadataInternal.sol';
/**
 * @title ERC721Metadata internal functions
 */
abstract contract TradescrowProfileMetadataInternal is ERC721MetadataInternal
{
    using UintUtils for uint256;


    /**
     * @notice get generated URI for given token
     * @return token URI
     */
    function _tokenURI(
        uint256 tokenId
    ) internal view virtual returns (string memory) {
        if (!_exists(tokenId)) revert ERC721Metadata__NonExistentToken();

        ERC721MetadataStorage.Layout storage l = ERC721MetadataStorage.layout();

        string memory tokenIdURI = l.tokenURIs[tokenId];
        string memory baseURI = l.baseURI;

        if (bytes(baseURI).length == 0) {
            return tokenIdURI;
        } else if (bytes(tokenIdURI).length > 0) {
            return string(abi.encodePacked(baseURI, tokenIdURI));
        } else {
            return string(abi.encodePacked(baseURI, tokenId.toString()));
        }
    }

}