// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9 <0.9.0;

import { Role } from "./Role.sol";

struct Channel {
    bytes16 uuid;
    bytes title;
    bytes description;
    address channelAddress;
    uint256 subscriptionPrice;
    uint256 createdAt;
    Role role;
    uint256 postsCount;
}