// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9 <0.9.0;

import { IGetPosts } from "contracts/IGetPosts.sol";
import { Channel } from "contracts/Channel.sol";
import { Post } from "contracts/Post.sol";

interface IBullet is IGetPosts {
    
    function createChannel(
        bytes memory title,
        bytes memory description,
        uint256 subscriptionPrice
    ) external;

    function getMyChannels() external view returns (address[] memory);
    function getPost(uint256 postId) external view returns (Post memory);
}