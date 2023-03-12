// SPDX-License-Identifier: GPL-V3
pragma solidity ^0.8.0;

import { TradeAssets as TA } from "../library/TradeAssets.sol";

interface ITradescrowEvents {
    event TradeCreated(address indexed from, uint256 indexed tradeId, TA.Trade trade);
    event TradeAccepted(address indexed from, uint256 indexed tradeId);
    event TradeRejected(address indexed from, uint256 indexed tradeId);
    event TradeCancelled(address indexed from, uint256 indexed tradeId);
    event DefaultFeeChanged(address indexed from, address indexed _address, uint256 indexed fee);
    event SpecificFeeSet(address indexed from, address indexed _address, uint256 indexed fee);
    event SpecificFeeRemoved(address indexed from, address indexed _address);
}