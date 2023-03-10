// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { AccessControl } from "@solidstate/contracts/access/access_control/AccessControl.sol";
import { Pausable } from "@solidstate/contracts/security/Pausable.sol";

import { TradescrowInternal } from "./TradescrowInternal.sol";
import { TradeAssets } from "./TradeAssets.sol";

import { ITradescrowAdmin } from "./ITradescrowAdmin.sol";

contract TradescrowAdmin is ITradescrowAdmin, TradescrowInternal, AccessControl, Pausable {

    constructor() {
        _grantRole(0x00, msg.sender);
    }

    function setFee(uint256 fee) external onlyRole(0x00) {
        _setFee(fee);
    }

    function pause() external onlyRole(0x00) {
        _pause();
    }

    function unpause() external onlyRole(0x00) {
        _unpause();
    }
}