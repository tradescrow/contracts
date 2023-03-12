// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { TradeAssets as TA } from "../library/TradeAssets.sol";

interface ITradescrowView {
    function getTradeById(uint256 tradeId) external view returns (TA.Trade memory);
}