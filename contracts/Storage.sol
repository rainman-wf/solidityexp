// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9 <0.9.0;

import { IStorage } from "contracts/IStorage.sol";
import { Post } from "contracts/Post.sol";
import { Role } from "contracts/Role.sol";
import { Bullet } from "contracts/Bullet.sol";
import "hardhat/console.sol";

contract Storage is IStorage {

    Post[] posts;

    mapping (address => address[]) userChannels;

    mapping (address => bool) trustedContract;

    modifier isTrusted() {
        require(trustedContract[msg.sender], "Untrusted contract address");
        _;
    }

    event bulletCreated(address indexed bulletAddress);

    constructor() {
        trustedContract[address(0x3981451C390Ef8B5c5C7132a5Ff65148111b3c94)]= true;
        address bullet = address(new Bullet(address(this)));
        trustedContract[bullet] = true;
        emit bulletCreated(bullet);
    }

    function savePost(
        bytes memory _content, 
        address _channelAddress, 
        bytes8 _encoding, 
        uint256 indexInChannel
        ) isTrusted external returns (uint256) {

        Post memory post = Post(posts.length, indexInChannel, 1, 0, block.timestamp, _content, _encoding, _channelAddress);
        posts.push(post);
        return posts.length - 1; 
    }

    function getPost(uint256 postId) isTrusted external view returns (Post memory) {
        return posts[postId];
    }

    function addChannelToUser(address channelAddress, address userAddress) isTrusted external {
        userChannels[userAddress].push(channelAddress);
    }

    function getUserChannels(address userAddress) isTrusted view  external returns (address[] memory) {
        return userChannels[userAddress];
    }

    function setTrusted(address contractAdddress) isTrusted external {
        trustedContract[contractAdddress] = true;
    }

    function getAddress() external view returns (address) {
        return address(this);
    }

    function getPosts(uint256[] memory indexes) isTrusted external view  returns (Post[] memory _posts) {
        for (uint256 i = 0; i < indexes.length; i++) {
            _posts[i] = posts[indexes[i]];
        }   
    }

    function getLatest(uint8 size) isTrusted external view returns (Post[] memory) {
        if (posts.length <= size) return posts;
        uint256 oldest = posts.length - size;
        Post[] memory result = new Post[](size);
        for (uint256 i = oldest; i <= posts.length - 1; i++)  result[i - oldest] = posts[i];
        return result;
    }

    function getAfter(uint256 offset, uint256 size) isTrusted external view returns (Post[] memory) {
        if (posts.length == 0) return new Post[](0); 
        uint256 lastIndex = posts.length - 1;
        if (offset + 1 >= lastIndex) return new Post[](0);
        uint256 oldest = offset + 1;
        uint256 newest = offset + size;
        if (newest > lastIndex) return new Post[](0);
        Post[] memory result = new Post[](newest - oldest + 1);
        for (uint256 i = oldest; i <= newest; i++) result[i - oldest] = posts[i];
        return result;
    }

    function getBefore(uint256 offset, uint256 size) isTrusted external view returns (Post[] memory) {
        if (posts.length == 0) return new Post[](0); 
        uint256 lastIndex = posts.length - 1;
        uint256 oldest = offset < size ? 0: offset - size;
        if (oldest > lastIndex) return new Post[](0);
        uint256 newest = offset > lastIndex ? lastIndex: offset;
        Post[] memory result = new Post[](newest - oldest + 1);
        for (uint256 i = oldest; i <= newest; i++) result[i - oldest] = posts[i];
        return result;
    }

}