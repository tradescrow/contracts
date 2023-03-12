// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { TradeAssets as TA } from "../library/TradeAssets.sol";

interface ITradescrowWrite {
    function createTrade(TA.Trade memory trade) external;
    function acceptTrade(uint256 tradeId) external;
    function cancelTrade(uint256 tradeId) external;
    function rejectTrade(uint256 tradeId) external;
}