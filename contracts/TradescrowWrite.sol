// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { TradescrowInternal } from "./TradescrowInternal.sol";
import { TradeAssets } from "./TradeAssets.sol";

import { ITradescrowWrite } from "./ITradescrowWrite.sol";

contract TradescrowWrite is ITradescrowWrite, TradescrowInternal {

    constructor() {}

    function createTrade(TradeAssets.Trade memory trade) external {
        _createTrade(trade);
    }

    function acceptTrade(uint256 tradeId) external {
        _acceptTrade(tradeId);
    }

    function cancelTrade(uint256 tradeId) external {
        _cancelTrade(tradeId);
    }

    function rejectTrade(uint256 tradeId) external {
        _rejectTrade(tradeId);
    }
}