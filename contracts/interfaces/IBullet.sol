// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9 <0.9.0;

import { IGetPosts } from "./IGetPosts.sol";
import { Channel } from "contracts/structs/Channel.sol";
import { Post } from "contracts/structs/Post.sol";

interface IBullet is IGetPosts {
    
    function createChannel(
        bytes16 uuid,
        bytes memory title,
        bytes memory description,
        uint256 subscriptionPrice
    ) external;

    function getMyChannels() external view returns (address[] memory);
    function getPost(uint256 postId) external view returns (Post memory);
}