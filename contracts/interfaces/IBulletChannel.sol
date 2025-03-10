// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9 <0.9.0;

import { Role } from "contracts/structs/Role.sol";
import { Channel } from "contracts/structs/Channel.sol";
import { Post } from "contracts/structs/Post.sol";
import { IGetPosts } from "./IGetPosts.sol";

interface IBulletChannel is IGetPosts {
    function createPost(bytes16 uuid, bytes memory content, bytes8 encoding, bytes[] memory hashtags) external ;
    function setRole(address user, Role role) external ;
    function subscribe() external payable;
    function donate() external payable;
    function withdraw(uint256 value) external ;

    function getInfo() external view returns (Channel memory);
    function updateInfo(bytes memory title, bytes memory description, uint256 subscriptionPrice) external;
    
    function getBalance() external view returns (uint256);
}