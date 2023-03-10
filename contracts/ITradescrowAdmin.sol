// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ITradescrowAdmin {

    function setFee(uint256 fee) external;
    function pause() external;
    function unpause() external;
}