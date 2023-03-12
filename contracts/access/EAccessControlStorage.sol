// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library EAccessControlStorage {
    bytes32 internal constant DEFAULT_ADMIN = 0x00;
    bytes32 internal constant ADMIN = keccak256('ADMIN_ROLE');
    bytes32 internal constant MANAGER = keccak256('MANAGER_ROLE');
    bytes32 internal constant SUPPORT = keccak256('SUPPORT_ROLE');
    bytes32 internal constant PARTNER = keccak256('PARTNER_ROLE');
}