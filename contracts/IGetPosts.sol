// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9 <0.9.0;

import { Post } from "contracts/Post.sol";

interface IGetPosts {
    function getLatest(uint8 size) external view returns (Post[] memory);
    function getAfter(uint256 offset, uint256 size) external view returns (Post[] memory);
    function getBefore(uint256 offset, uint256 size) external view returns (Post[] memory);
    function getPost(uint256 postId) external view returns (Post memory);
}

