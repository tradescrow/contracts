// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { Pausable } from "@solidstate/contracts/security/Pausable.sol";

import { TradescrowInternal } from "./TradescrowInternal.sol";
import { EAccessControl } from "../access/EAccessControl.sol";
import { EAccessControlStorage } from "../access/EAccessControlStorage.sol";
import { ITradescrowAdmin } from "./ITradescrowAdmin.sol";

contract TradescrowAdmin is ITradescrowAdmin, TradescrowInternal, EAccessControl, Pausable {

    constructor() {
        _grantRole(EAccessControlStorage.DEFAULT_ADMIN, msg.sender);
        _grantRole(EAccessControlStorage.ADMIN, msg.sender);
        _grantRole(EAccessControlStorage.MANAGER, msg.sender);
        _grantRole(EAccessControlStorage.SUPPORT, msg.sender);
        _grantRole(EAccessControlStorage.PARTNER, msg.sender);
    }

    function setDefaultFee(address _address, uint256 fee) external onlyAdmin {
        _setDefaultFee(_address, fee);
    }

    function setDefaultFeeAddress(address _address) external onlyAdmin {
        _setDefaultFeeAddress(_address);
    }

    function setDefaultFeeAmount(uint256 fee) external onlyAdmin {
        _setDefaultFeeAmount(fee);
    }

    function setSpecificFee(address _address, uint256 fee) external onlyManager {
        _setFeeOf(_address, fee);
    }

    function clearSpecificFee(address _address) external onlyManager {
        _removeFeeOf(_address);
    }

    function pause() external onlyManager {
        _pause();
    }

    function unpause() external onlyManager {
        _unpause();
    }
}