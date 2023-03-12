// SPDX-License-Identifier: GPL-V3
pragma solidity ^0.8.0;

import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

import { EnumerableTradeMap } from "../library/EnumerableTradeMap.sol";
import { TradeAssets as TA } from "../library/TradeAssets.sol";
import { EnumerableMap } from "../library/EnumerableMap.sol";

library TradescrowStorage {
    using EnumerableTradeMap for EnumerableTradeMap.UintToTradeMap;
    using EnumerableMap for EnumerableMap.AddressToUintMap;
    using TradescrowStorage for TradescrowStorage.Layout;

    // Counter to separate swaps
    using Counters for Counters.Counter;

    bytes32 internal constant STORAGE_SLOT = keccak256("Tradescrow.contracts.storage.core");
    uint256 internal constant BASIS_POINTS = 10_000;

    struct Layout {
        Counters.Counter counter;
        // eth locked temporary storage (unused)
        uint256 eth;
        // fee storage
        TA.ERC20Asset defaultFee;
        // deposit percent
        uint256 depositPercent;
        // Mapping for trades
        EnumerableTradeMap.UintToTradeMap trades;
        // Mapping for specific tiered fees;
        EnumerableMap.AddressToUintMap fees;
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

    function addTrade(Layout storage l, uint256 tradeId, TA.Trade memory trade) internal {
        l.trades.add(tradeId, trade);
    }

    function getTrades(Layout storage l) internal view returns (uint256[] memory, TA.Trade[] memory) {
        return l.trades.toArray();
    }

    function _getTradeById(Layout storage l, uint256 tradeId) internal view returns (TA.Trade memory) {
        return l.trades.get(tradeId);
    }

    function removeTrade(Layout storage l, uint256 tradeId) internal {
        l.trades.remove(tradeId);
    }

    function __getDefaultFee(Layout storage l) internal view returns (TA.ERC20Asset memory) {
        return l.defaultFee;
    }

    function __setDefaultFeeAmount(Layout storage l, uint256 amount) internal {
        l.defaultFee.amount = amount;
    }

    function __setDefaultFeeAddress(Layout storage l, address _address) internal {
        l.defaultFee._address = _address;
    }

    function __getFeeOf(Layout storage l, address _address) internal view returns (uint256) {
        if (l.fees.contains(_address)) {
            return l.fees.get(_address);
        }
        return l.defaultFee.amount;
    }

    function __setFeeOf(Layout storage l, address _address, uint256 fee) internal {
        l.fees.set(_address, fee);
    }

    function __removeFeeOf(Layout storage l, address _address) internal {
        l.fees.remove(_address);
    }

    function __getDepositFee(Layout storage l, address _address) internal view returns (TA.ERC20Asset memory) {
        uint256 fee = l.__getFeeOf(_address);
        return TA.ERC20Asset({
            _address: l.defaultFee._address,
            amount: fee > 0 ? fee * l.depositPercent / BASIS_POINTS : 0
        });
    }

    function __getCompletionFee(Layout storage l, address _address) internal view returns (TA.ERC20Asset memory) {
        uint256 fee = l.__getFeeOf(_address);
        return TA.ERC20Asset({
            _address: l.defaultFee._address,
            amount: fee > 0 ? fee - l.__getDepositFee(_address).amount : 0
        });
    }
}