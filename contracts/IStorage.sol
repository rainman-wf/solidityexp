// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9 <0.9.0;
import { Role } from "contracts/Role.sol";
import { Post } from "contracts/Post.sol";
import { IGetPosts } from "contracts/IGetPosts.sol";

interface IStorage is IGetPosts {

    function getAddress() external view returns (address);

    function savePost(bytes memory _content, address _channelAddress, bytes8 _encoding, uint256 indexInChannel) external returns (uint256);
    function addChannelToUser(address channelAddress, address userAddress) external ;
    function getUserChannels(address userAddress) external view returns (address[] memory);
    function setTrusted(address contractAdddress) external ;
    function getPosts(uint256[] memory indexes) external  view returns (Post[] memory);
}