// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { PausableInternal } from "@solidstate/contracts/security/PausableInternal.sol";
import { ReentrancyGuard } from "@solidstate/contracts/utils/ReentrancyGuard.sol";
import { SafeERC20 } from "@solidstate/contracts/utils/SafeERC20.sol";
import { IERC20 } from "@solidstate/contracts/interfaces/IERC20.sol";

import { ITradescrowInternal } from "./ITradescrowInternal.sol";
import { TradeAssets as TA } from "../library/TradeAssets.sol";
import { ITradescrowEvents } from "./ITradescrowEvents.sol";
import { TradescrowStorage } from "./TradescrowStorage.sol";

contract TradescrowInternal is
    ITradescrowInternal,
    ITradescrowEvents,
    ReentrancyGuard,
    PausableInternal
{
    using TradescrowStorage for TradescrowStorage.Layout;
    using TA for TA.Trade;
    using TA for TA.Assets;
    using TA for TA.ERC20Asset;
    // Use SafeERC20 for best practice
    using SafeERC20 for IERC20;

    constructor() {}


    /********
     * Core *
     ********/

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
    function _createTrade(TA.Trade memory trade) internal whenNotPaused nonReentrant returns (uint256 tradeId) {
        tradeId = TradescrowStorage.layout().nextTradeId();
        if (trade.hasEmpty()) revert Tradescrow__EmptyAssets();
        if (!trade.offer.isApproved()) revert Tradescrow__NotApproved();

        _beforeCreateTrade(trade);

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
    function _acceptTrade(uint256 tradeId) internal whenNotPaused nonReentrant {
        TA.Trade memory trade = TradescrowStorage.layout()._getTradeById(tradeId);
        if (trade.desired.user != msg.sender) revert Tradescrow__NotParticipant();

        _beforeAcceptTrade(trade);
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
    function _cancelTrade(uint256 tradeId) internal whenNotPaused nonReentrant {
        TA.Trade memory trade = TradescrowStorage.layout()._getTradeById(tradeId);
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
    function _rejectTrade(uint256 tradeId) internal whenNotPaused nonReentrant {
        TA.Trade memory trade = TradescrowStorage.layout()._getTradeById(tradeId);
        if (trade.desired.user != msg.sender) revert Tradescrow__NotParticipant();
        TradescrowStorage.layout().removeTrade(tradeId);
        emit TradeRejected(msg.sender, tradeId);
    }

    /********
     * View *
     ********/

    function _geDefaultFee() internal view returns (address, uint256) {
        return (TradescrowStorage.layout().defaultFee._address, TradescrowStorage.layout().defaultFee.amount);
    }


    function _getTradeById(uint256 tradeId) internal view returns (TA.Trade memory) {
        return TradescrowStorage.layout()._getTradeById(tradeId);
    }

    function _getFeeOf(address _address) internal view returns (uint256) {
        return TradescrowStorage.layout().__getFeeOf(_address);
    }

    function _getActiveTrades() internal view returns (uint256[] memory tradeIds, TA.Trade[] memory trades) {
        (tradeIds, trades) = TradescrowStorage.layout().getTrades();
    }

    function _getActiveTradesOf(address user) internal view returns (uint256[] memory ids, TA.Trade[] memory trades) {
        (uint256[] memory allTradeIds, TA.Trade[] memory allTrades) = TradescrowStorage.layout().getTrades();
        uint256 fullLen = allTradeIds.length;
        uint256[] memory matching = new uint256[](fullLen);
        uint256 count = 0;
        for (uint256 i = 0; i < fullLen; i++) {
            if (allTrades[i].offer.user == user || allTrades[i].desired.user == user) {
                matching[count] = i;
                count++;
            }
        }
        ids = new uint256[](count);
        trades = new TA.Trade[](count);
        for (uint256 i = 0; i < count; i++) {
            ids[i] = allTradeIds[matching[i]];
            trades[i] = allTrades[matching[i]];
        }
    }

    /*********
     * Admin *
     *********/


    function _setDefaultFee(address _address, uint256 fee) internal {
        TradescrowStorage.layout().__setDefaultFeeAddress(_address);
        TradescrowStorage.layout().__setDefaultFeeAmount(fee);
        emit DefaultFeeChanged(msg.sender, _address, fee);
    }

    function _setDefaultFeeAddress(address _address) internal {
        TradescrowStorage.layout().__setDefaultFeeAddress(_address);
        emit DefaultFeeChanged(msg.sender, _address, TradescrowStorage.layout().defaultFee.amount);
    }

    function _setDefaultFeeAmount(uint256 fee) internal {
        TradescrowStorage.layout().__setDefaultFeeAmount(fee);
        emit DefaultFeeChanged(msg.sender, TradescrowStorage.layout().defaultFee._address, fee);
    }

    function _setFeeOf(address _address, uint256 fee) internal {
        TradescrowStorage.layout().__setFeeOf(_address, fee);
        emit SpecificFeeSet(msg.sender, _address, fee);
    }

    function _removeFeeOf(address _address) internal {
        TradescrowStorage.layout().__removeFeeOf(_address);
    }

    /*********
     * Hooks *
     *********/

    function _beforeCreateTrade(TA.Trade memory trade) internal {
        TradescrowStorage.layout().__getDepositFee(address(0)).transfer(trade.offer.user, address(this));
    }

    function _beforeAcceptTrade(TA.Trade memory trade) internal {
        TradescrowStorage.layout().__getCompletionFee(address(0)).transfer(trade.offer.user, address(this));
    }
}