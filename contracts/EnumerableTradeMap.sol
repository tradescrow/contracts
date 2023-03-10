// SPDX-License-Identifier: GPL-V3
pragma solidity ^0.8.0;

import { TradeAssets as T } from "./TradeAssets.sol";
/**
 * @title Map implementation with enumeration functions
 * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts (MIT license)
 */
library EnumerableTradeMap {
    error EnumerableTradeMap__IndexOutOfBounds(uint256 index);
    error EnumerableTradeMap__NonExistentKey(uint256 key);

    struct MapEntry {
        uint256 _key;
        T.Trade _value;
    }

    struct UintToTradeMap {
        MapEntry[] _entries;
        // 1-indexed to allow 0 to signify nonexistence
        mapping(uint256 => uint256) _indexes;
    }

    function at(UintToTradeMap storage map, uint256 index) internal view returns (uint256, T.Trade storage) {
        if (index >= map._entries.length)
            revert EnumerableTradeMap__IndexOutOfBounds(index);
        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function contains(UintToTradeMap storage map, uint256 key) internal view returns (bool) {
        return map._indexes[key] != 0;
    }

    function length(UintToTradeMap storage map) internal view returns (uint256) {
        return map._entries.length;
    }

    function get(UintToTradeMap storage map, uint256 key) internal view returns (T.Trade memory) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) revert EnumerableTradeMap__NonExistentKey(key);
        unchecked {
            return map._entries[keyIndex - 1]._value;
        }
    }

    function add(UintToTradeMap storage map, uint256 key, T.Trade memory value) internal returns (bool) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) {
            MapEntry storage me = map._entries[map._entries.length];
            me._key = key;
            T.Trade storage trade = me._value;
            T.Assets storage offer = trade.offer;
            offer.user = value.offer.user;
            offer.eth = value.offer.eth;
            uint256 len = value.offer.erc20Assets.length;
            for (uint256 i = 0; i < len; i++) {
                offer.erc20Assets.push(T.ERC20Asset({
                    _address: value.offer.erc20Assets[i]._address,
                    amount: value.offer.erc20Assets[i].amount
                }));
            }
            len = value.offer.erc1155Assets.length;
            for (uint256 i = 0; i < len; i++) {
                T.ERC1155Asset storage a = offer.erc1155Assets[i];
                a._address = value.offer.erc1155Assets[i]._address;
                uint256 sublen = value.offer.erc1155Assets[i].assets.length;
                for (uint256 j = 0; j < sublen; j++) {
                    a.assets.push(T.ERC1155SingleAsset({
                        id: value.offer.erc1155Assets[i].assets[j].id,
                        amount: value.offer.erc1155Assets[i].assets[j].amount
                    }));
                }
            }
            len = value.offer.erc721Assets.length;
            for (uint256 i = 0; i < len; i++) {
                T.ERC721Asset storage a = offer.erc721Assets[i];
                a._address = value.offer.erc721Assets[i]._address;
                uint256 sublen = value.offer.erc721Assets[i].tokenIds.length;
                for (uint256 j = 0; j < sublen; j++) {
                    a.tokenIds.push(value.offer.erc721Assets[i].tokenIds[j]);
                }
            }
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(UintToTradeMap storage map, uint256 key) internal returns (bool) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex != 0) {
            unchecked {
                MapEntry storage last = map._entries[map._entries.length - 1];
                // move last entry to now-vacant index
                map._entries[keyIndex - 1] = last;
                map._indexes[last._key] = keyIndex;
            }
            // clear last index
            map._entries.pop();
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function toArray(UintToTradeMap storage map) internal view returns (uint256[] memory, T.Trade[] memory) {
        uint256 len = map._entries.length;

        uint256[] memory keysOut = new uint256[](len);
        T.Trade[] memory valuesOut = new T.Trade[](len);

        unchecked {
            for (uint256 i; i < len; ++i) {
                keysOut[i] = map._entries[i]._key;
                valuesOut[i] = map._entries[i]._value;
            }
        }

        return (keysOut, valuesOut);
    }

    function keys(UintToTradeMap storage map) internal view returns (uint256[] memory) {
        uint256 len = map._entries.length;
        uint256[] memory keysOut = new uint256[](len);
        unchecked {
            for (uint256 i; i < len; ++i) {
                keysOut[i] = map._entries[i]._key;
            }
        }
        return keysOut;
    }

    function values(UintToTradeMap storage map) internal view returns (T.Trade[] memory) {
        uint256 len = map._entries.length;
        T.Trade[] memory valuesOut = new T.Trade[](len);

        unchecked {
            for (uint256 i; i < len; ++i) {
                valuesOut[i] = map._entries[i]._value;
            }
        }

        return valuesOut;
    }
}