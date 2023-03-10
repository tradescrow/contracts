// SPDX-License-Identifier: GPL-V3
pragma solidity ^0.8.0;

interface ITradescrowInternal {
    error Tradescrow__EmptyAssets();
    error Tradescrow__NotApproved();
    error Tradescrow__NotParticipant();
}