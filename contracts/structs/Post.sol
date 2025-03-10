// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9 <0.9.0;
    
struct Post {
    bytes16 uuid;
    uint256 globalIndex;
    uint256 postIndexInChannel;
    uint8 major;
    uint8 minor;
    uint256 publishedAt;
    bytes content;
    bytes8 encoding;
    address channelAddress;
    address author;
}