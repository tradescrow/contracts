// SPDX-License-Identifier: GPL-V3
pragma solidity ^0.8.0;
import { SafeERC20 } from "@solidstate/contracts/utils/SafeERC20.sol";
import { IERC20 } from "@solidstate/contracts/interfaces/IERC20.sol";
import { IERC1155 } from "@solidstate/contracts/interfaces/IERC1155.sol";
import { IERC721 } from "@solidstate/contracts/interfaces/IERC721.sol";

library TradeAssets {
    using SafeERC20 for IERC20;
    using TradeAssets for ERC20Asset;
    using TradeAssets for ERC1155Asset;
    using TradeAssets for ERC721Asset;
    using TradeAssets for Assets;

    struct ERC20Asset {
        address _address;
        uint256 amount;
    }

    struct ERC1155SingleAsset {
        uint256 id;
        uint256 amount;
    }

    struct ERC1155Asset {
        address _address;
        ERC1155SingleAsset[] assets;
    }

    struct ERC721Asset {
        address _address;
        uint256[] tokenIds;
    }

    struct Assets {
        address user;
        uint256 eth;
        ERC20Asset[] erc20Assets;
        ERC1155Asset[] erc1155Assets;
        ERC721Asset[] erc721Assets;
    }

    struct Trade {
        Assets offer;
        Assets desired;
    }

    function Contract(ERC20Asset memory asset) internal pure returns (IERC20) {
        return IERC20(asset._address);
    }

    function Contract(ERC1155Asset memory asset) internal pure returns (IERC1155) {
        return IERC1155(asset._address);
    }

    function Contract(ERC721Asset memory asset) internal pure returns (IERC721) {
        return IERC721(asset._address);
    }

    function isApproved(ERC20Asset memory asset, address holder) internal view returns (bool) {
        return asset.Contract().allowance(holder, address(this)) >= asset.amount;
    }

    function isApproved(ERC1155Asset memory asset, address account) internal view returns (bool) {
        return asset.Contract().isApprovedForAll(account, address(this));
    }

    function isApproved(ERC721Asset memory asset, address account) internal view returns (bool) {
        return asset.Contract().isApprovedForAll(account, address(this));
    }

    function isApproved(Assets memory assets) internal view returns (bool) {
        uint256 len = assets.erc20Assets.length;
        for (uint256 i = 0; i < len; i++) {
            if (!assets.erc20Assets[i].isApproved(assets.user)) return false;
        }
        len = assets.erc1155Assets.length;
        for (uint256 i = 0; i < len; i++) {
            if (!assets.erc1155Assets[i].isApproved(assets.user)) return false;
        }
        len = assets.erc721Assets.length;
        for (uint256 i = 0; i < len; i++) {
            if (!assets.erc721Assets[i].isApproved(assets.user)) return false;
        }
        return true;
    }

    function isEmpty(Assets memory assets) internal pure returns (bool) {
        return (assets.erc20Assets.length + assets.erc1155Assets.length + assets.erc721Assets.length) == 0;
    }

    function hasEmpty(Trade memory trade) internal pure returns (bool) {
        return (trade.desired.isEmpty() || trade.offer.isEmpty());
    }

    function transfer(ERC20Asset memory asset, address from, address to) internal {
        asset.Contract().transferFrom(from, to, asset.amount);
    }

    function transfer(ERC1155Asset memory asset, address from, address to) internal {
        uint256 len = asset.assets.length;
        uint256[] memory ids = new uint256[](len);
        uint256[] memory amounts = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            ids[i] = asset.assets[i].id;
            amounts[i] = asset.assets[i].amount;
        }
        asset.Contract().safeBatchTransferFrom(from, to, ids, amounts, "");
    }

    function transfer(ERC721Asset memory asset, address from, address to) internal {
        uint256 len = asset.tokenIds.length;
        for (uint256 i = 0; i < len; i++) {
            asset.Contract().safeTransferFrom(from, to, asset.tokenIds[i]);
        }
    }

    function transfer(Assets memory assets, address to) internal {
        uint256 len = assets.erc20Assets.length;
        for (uint256 i = 0; i < len; i++) {
            assets.erc20Assets[i].transfer(assets.user, to);
        }
        len = assets.erc1155Assets.length;
        for (uint256 i = 0; i < len; i++) {
            assets.erc1155Assets[i].transfer(assets.user, to);
        }
        len = assets.erc721Assets.length;
        for (uint256 i = 0; i < len; i++) {
            assets.erc721Assets[i].transfer(assets.user, to);
        }
    }

    function transfer(Trade memory trade) internal {
        trade.desired.transfer(trade.offer.user);
        trade.offer.transfer(trade.desired.user);
    }
}