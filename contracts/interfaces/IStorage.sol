// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9 <0.9.0;
import { Role } from "contracts/structs/Role.sol";
import { Post } from "contracts/structs/Post.sol";
import { IGetPosts } from "./IGetPosts.sol";

interface IStorage is IGetPosts {

    function getAddress() external view returns (address);

    function savePost(bytes16 uuid, bytes memory _content, address author, address _channelAddress, bytes8 _encoding, uint256 indexInChannel, bytes[] memory hashtags) external returns (uint256);
    function addChannelToUser(address channelAddress, address userAddress) external ;
    function getUserChannels(address userAddress) external view returns (address[] memory);
    function setTrusted(address contractAdddress) external ;
    function getPosts(uint256[] memory indexes) external  view returns (Post[] memory);
}