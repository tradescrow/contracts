// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { TradeAssets as TA } from "../library/TradeAssets.sol";
import { TradescrowInternal } from "./TradescrowInternal.sol";
import { ITradescrowView } from "./ITradescrowView.sol";

contract TradescrowView is ITradescrowView, TradescrowInternal {

    constructor() {}

    function getDefaultFee() external view returns (address, uint256) {
        return _geDefaultFee();
    }

    function getTradeById(uint256 tradeId) external view returns (TA.Trade memory) {
        return _getTradeById(tradeId);
    }

    function getActiveTrades() external view returns (uint256[] memory ids, TA.Trade[] memory trades) {
        return _getActiveTrades();
    }

    function getActiveTradesOf(address user) external view returns (uint256[] memory ids, TA.Trade[] memory trades) {
        return _getActiveTradesOf(user);
    }
}