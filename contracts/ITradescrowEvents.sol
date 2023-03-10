// SPDX-License-Identifier: GPL-V3
pragma solidity ^0.8.0;

import { TradeAssets } from "./TradeAssets.sol";

interface ITradescrowEvents {
    event TradeCreated(address indexed from, uint256 indexed tradeId, TradeAssets.Trade trade);
    event TradeAccepted(address indexed from, uint256 indexed tradeId);
    event TradeRejected(address indexed from, uint256 indexed tradeId);
    event TradeCancelled(address indexed from, uint256 indexed tradeId);
    event FeeChanged(address indexed from, uint256 indexed fee);
}