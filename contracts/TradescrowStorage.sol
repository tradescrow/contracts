// SPDX-License-Identifier: GPL-V3
pragma solidity ^0.8.0;

import { EnumerableSet, ERC1155EnumerableStorage } from "@solidstate/contracts/token/ERC1155/enumerable/ERC1155EnumerableStorage.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";
import { EnumerableTradeMap } from "./EnumerableTradeMap.sol";
import { TradeAssets } from "./TradeAssets.sol";

library TradescrowStorage {
    using TradescrowStorage for TradescrowStorage.Layout;
    using EnumerableTradeMap for EnumerableTradeMap.UintToTradeMap;
    // Counter to separate swaps
    using Counters for Counters.Counter;

    enum TokenType {
        ERC20,
        ERC1155,
        ERC721
    }

    bytes32 internal constant STORAGE_SLOT = keccak256("Tradescrow.contracts.storage.Tradescrow");

    struct Layout {
        Counters.Counter counter;
        // eth locked temporary storage
        uint256 eth;
        // fee storage
        uint256 fee;
        // Storage mapping for trades
        EnumerableTradeMap.UintToTradeMap trades;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function nextTradeId(Layout storage l) internal returns (uint256) {
        l.counter.increment();
        return l.counter.current();
    }

    function addTrade(Layout storage l, uint256 tradeId, TradeAssets.Trade memory trade) internal {
        l.trades.add(tradeId, trade);
    }

    function _getTradeById(Layout storage l, uint256 tradeId) internal view returns (TradeAssets.Trade memory) {
        return l.trades.get(tradeId);
    }

    function removeTrade(Layout storage l, uint256 tradeId) internal {
        l.trades.remove(tradeId);
    }
}