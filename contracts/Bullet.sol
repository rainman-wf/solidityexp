// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9 <0.9.0;

import { IBullet } from "contracts/interfaces/IBullet.sol";
import { IGetPosts } from "contracts/interfaces/IGetPosts.sol";
import { Post } from "contracts/structs/Post.sol";
import { IStorage } from "contracts/interfaces/IStorage.sol";
import { BulletChannel } from "./BulletChannel.sol";
import { Channel } from "contracts/structs/Channel.sol";
import { IBulletChannel } from "contracts/interfaces/IBulletChannel.sol";

contract Bullet is IBullet {

    IStorage _storage;

    constructor (address strorageAddress) {
        _storage = IStorage(strorageAddress);
    }

    event channelCreated(address indexed channelAddress);

    function createChannel(
        bytes16 uuid,
        bytes memory title,
        bytes memory description,
        uint256 subscriptionPrice
    ) external {
        
        address newBulletAddress = address(
            new BulletChannel(
                uuid,
                _storage.getAddress(),
                title, 
                description, 
                subscriptionPrice,
                msg.sender
            )
        );
        _storage.setTrusted(newBulletAddress);
        _storage.addChannelToUser(newBulletAddress, msg.sender);
        emit channelCreated(newBulletAddress);
    }

    function getPostsByHashtag(bytes memory hashtag) external view returns (Post[] memory) {    
        return _storage.getPostsByHashtag(hashtag);
    }

    function getMyChannels() external view returns (address[] memory) {
        return _storage.getUserChannels(msg.sender);
    }

    function getLatest(uint8 size) external view returns (Post[] memory) {
        return _storage.getLatest(size);
    }

    function getAfter(uint256 offset, uint256 size) external view returns (Post[] memory) {
        return _storage.getAfter(offset, size);
    }

    function getBefore(uint256 offset, uint256 size) external view returns (Post[] memory) {
        return _storage.getBefore(offset, size);
    }

    function getPost(uint256 postId) external view returns (Post memory) {
        return _storage.getPost(postId);
    }
}