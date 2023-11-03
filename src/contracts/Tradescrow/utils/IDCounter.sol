// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Counters} from "../libraries/Counters.sol";

abstract contract IDCounter is Initializable {
    using Counters for Counters.Counter;

    Counters.Counter private _counter;

    // solhint-disable-next-line func-name-mixedcase
    function __idCounter_init() internal onlyInitializing {
        if (_counter.current() == 0) {
            _counter.increment();
        }
    }

    function newID() internal returns (uint256) {
        _counter.increment();
        return _counter.current();
    }

    function isValidTradeId(uint256 id) public view returns (bool) {
        return id <= _counter.current();
    }

    uint256[48] private __gap;
}
