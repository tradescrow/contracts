// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { TradeAssets } from "./TradeAssets.sol";

interface ITradescrowWrite {
    function createTrade(TradeAssets.Trade memory trade) external;
    function acceptTrade(uint256 tradeId) external;
    function cancelTrade(uint256 tradeId) external;
    function rejectTrade(uint256 tradeId) external;
}