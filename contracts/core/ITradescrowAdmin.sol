// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ITradescrowAdmin {
    function setDefaultFee(address _address, uint256 fee) external;
    function setDefaultFeeAddress(address _address) external;
    function setDefaultFeeAmount(uint256 fee) external;
    function setSpecificFee(address _address, uint256 fee) external;
    function clearSpecificFee(address _address) external;

    function pause() external;
    function unpause() external;
}