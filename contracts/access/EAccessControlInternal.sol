// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import { AccessControlInternal } from "@solidstate/contracts/access/access_control/AccessControlInternal.sol";
import { EAccessControlStorage } from "./EAccessControlStorage.sol";

/**
 * @title Role-based access control system
 * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts (MIT license)
 */

abstract contract EAccessControlInternal is AccessControlInternal {

    modifier onlyDefaultAdmin() {
        _checkRole(EAccessControlStorage.DEFAULT_ADMIN);
        _;
    }

    modifier onlyAdmin() {
        _checkRole(EAccessControlStorage.ADMIN);
        _;
    }

    modifier onlyManager() {
        _checkRole(EAccessControlStorage.MANAGER);
        _;
    }

    modifier onlySupport() {
        _checkRole(EAccessControlStorage.SUPPORT);
        _;
    }

    modifier onlyPartner() {
        _checkRole(EAccessControlStorage.PARTNER);
        _;
    }
}