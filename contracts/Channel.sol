// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9 <0.9.0;

import { Role } from "contracts/Role.sol";

struct Channel {
    bytes description;
    bytes title;
    address channelAddress;
    uint256 subscriptionPrice;
    Role myRole;
}