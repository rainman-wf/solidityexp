// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9 <0.9.0;

import { Role } from "contracts/Role.sol";
import { Channel } from "contracts/Channel.sol";
import { Post } from "contracts/Post.sol";
import { IGetPosts } from "contracts/IGetPosts.sol";

interface IBulletChannel is IGetPosts {
    function createPost(bytes memory content, bytes8 encoding) external ;
    function setRole(address user, Role role) external ;
    function subscribe() external payable;
    function donate() external payable;
    function withdraw(uint256 value) external ;

    function getInfo() external view returns (Channel memory);
    function updateInfo(bytes memory title, bytes memory description, uint256 subscriptionPrice) external;
    
    function getBalance() external view returns (uint256);
    function getSubscribers() external view returns (address[] memory);
    function getPublishers() external view returns (address[] memory);
}