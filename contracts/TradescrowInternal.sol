// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { SafeERC20 } from "@solidstate/contracts/utils/SafeERC20.sol";
import { ISolidStateERC20 } from "@solidstate/contracts/token/ERC20/ISolidStateERC20.sol";

import { ITradescrowInternal } from "./ITradescrowInternal.sol";
import { TradeAssets } from "./TradeAssets.sol";
import { ITradescrowEvents } from "./ITradescrowEvents.sol";
import { TradescrowStorage } from "./TradescrowStorage.sol";

contract TradescrowInternal is ITradescrowInternal, ITradescrowEvents {
    using TradeAssets for TradeAssets.Trade;
    using TradeAssets for TradeAssets.Assets;
    using TradescrowStorage for TradescrowStorage.Layout;
    // Use SafeERC20 for best practice
    using SafeERC20 for ISolidStateERC20;

    // Sets the initial fee
    constructor() {
        TradescrowStorage.layout().fee = 5_000_000;
    }

    /**
    * @notice Create a new trade and pay the fee
    *
    * @dev Step 1: User proposes a trade to another address that contains any combination of
    *      ERC721/ERC1155/ERC20. No assets are transferred to this contract. Approval is checked
    *      for each asset offered.
    *
    * @param trade the Trade definition of offered and desired assets
    *
    * @return tradeId ID of the new trade
    */
    function _createTrade(TradeAssets.Trade memory trade) internal returns (uint256 tradeId) {
        tradeId = TradescrowStorage.layout().nextTradeId();

        if (trade.hasEmpty()) revert Tradescrow__EmptyAssets();
        if (!trade.offer.isApproved()) revert Tradescrow__NotApproved();

        TradescrowStorage.layout().addTrade(tradeId, trade);

        emit TradeCreated(msg.sender, tradeId, trade);

        return tradeId;
    }

    /**
    * @notice Accept the proposed swap offer sent from the target
    *
    * @dev Step 3: Swap initiator accepts the proposed swap from the target, which transfers
    *      all assets to their intended parties from this contract. This can only be called by
    *      the initiator of the swap, and only when the target has proposed their offer
    *
    * @param tradeId ID of the swap that the initiator wants to execute
    */
    function _acceptTrade(uint256 tradeId) internal {
        TradeAssets.Trade memory trade = TradescrowStorage.layout()._getTradeById(tradeId);
        if (trade.desired.user != msg.sender) revert Tradescrow__NotParticipant();

        // transfer assets
        trade.transfer();

        TradescrowStorage.layout().removeTrade(tradeId);
        emit TradeAccepted(msg.sender, tradeId);

    }

    /**
    * @notice Cancel the incomplete swap, returning all assets to their original owners
    * @dev Reverts all prior deposits, sending the assets back to their original owners
    *
    * @param tradeId ID of the swap that the swap participants want to cancel
    */
    function _cancelTrade(uint256 tradeId) internal {
        TradeAssets.Trade memory trade = TradescrowStorage.layout()._getTradeById(tradeId);
        if (trade.offer.user != msg.sender) revert Tradescrow__NotParticipant();
        TradescrowStorage.layout().removeTrade(tradeId);
        emit TradeCancelled(msg.sender, tradeId);
    }

    /**
     * @notice Cancel the incomplete swap, returning all assets to their original owners
     * @dev Reverts all prior deposits, sending the assets back to their original owners
     *
     * @param tradeId ID of the swap that the swap participants want to cancel
     */
    function _rejectTrade(uint256 tradeId) internal {
        TradeAssets.Trade memory trade = TradescrowStorage.layout()._getTradeById(tradeId);
        if (trade.desired.user != msg.sender) revert Tradescrow__NotParticipant();
        TradescrowStorage.layout().removeTrade(tradeId);
        emit TradeRejected(msg.sender, tradeId);
    }

    function _setFee(uint256 fee) internal {
        TradescrowStorage.layout().fee = fee;
        emit FeeChanged(msg.sender, fee);
    }
}