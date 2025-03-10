// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9 <0.9.0;

import { IBulletChannel } from "contracts/interfaces/IBulletChannel.sol";
import { Role } from "contracts/structs/Role.sol";
import { Channel } from "contracts/structs/Channel.sol";
import { Post } from "contracts/structs/Post.sol";
import { IStorage } from "contracts/interfaces/IStorage.sol";

contract BulletChannel is IBulletChannel {

    IStorage bulletStorage;

    address owner;
    bytes title;
    bytes description;
    uint256 subscriptionPrice;
    bytes16 uuid;

    uint256 createdAt;

    uint256[] indexes;
    
    mapping (address => Role) roles;

    event postCreated(uint256 indexed globalId);
    event subscribed(address indexed channelAddress);
    event donated(address indexed channelAddress);
    event withdrawn(address indexed channelAddress);
    event channelUpdated(address indexed channelAddress);

    modifier isOwner() {
        require (msg.sender == owner, "No access rights: Only owner can call this function");
        _;
    } 

    modifier isReader () {
        require(subscriptionPrice == 0 || (subscriptionPrice > 0 && roles[msg.sender] != Role.NONE), "No access rights: Only owner/publisher/subsriber can call this function");
        _;
    }

    modifier isPublisher () {
        require(msg.sender == owner || roles[msg.sender] == Role.PUBLISHER, "No access rights: Only publisher/owner can call this function");
        _;
    }

    constructor(bytes16 _uuid, address _storage, bytes memory _title, bytes memory _description, uint256 _price, address _owner) {
        uuid = _uuid;
        bulletStorage = IStorage(_storage);
        title = _title;
        description = _description;
        subscriptionPrice = _price;
        owner = _owner;
        createdAt = block.timestamp;
    }

    function getPostsByHashtag(bytes memory hashtag) external view returns (Post[] memory) {
        return bulletStorage.getPostsByHashtag(hashtag);
    }

    function createPost(bytes16 _uuid, bytes memory content, bytes8 encoding, bytes[] memory hashtags) isPublisher external {
        uint256 globalId = bulletStorage.savePost(_uuid, content, msg.sender, address(this), encoding, indexes.length, hashtags);    
        indexes.push(globalId);
        emit postCreated(globalId);
    }

    function setRole(address user, Role role) isOwner external {
        if (role == Role.OWNER) {
            owner = user;
            roles[msg.sender] = Role.PUBLISHER;
        } else roles[user] = role;
        bulletStorage.addChannelToUser(address(this), user);
    }

    function subscribe() external payable {
        require(roles[msg.sender] == Role.NONE, "You already have role subscriber or hier");
        require(msg.value >= subscriptionPrice, "Value is too low");
        roles[msg.sender] = Role.SUBSCRIBER;
        bulletStorage.addChannelToUser(address(this), msg.sender);
        emit subscribed(address(this));
    }

    function donate() external payable {
        emit donated(address(this));
    }

    function withdraw(uint256 value) isOwner external {
        (bool ok, ) = msg.sender.call{ value: value }("");
        require(ok, "Transfer failed");
    }

    function getInfo() external view returns (Channel memory) {
        Role role;
        if (msg.sender == owner) role = Role.OWNER; 
        else role = roles[msg.sender];
        return Channel(uuid, title, description, address(this), subscriptionPrice, createdAt, role, indexes.length);
    }
    
    function updateInfo(bytes memory _title, bytes memory _description, uint256 _subscriptionPrice) external {
        require (
            keccak256(_title) != keccak256(title) &&
            keccak256(_description) != keccak256(description) &&
             _subscriptionPrice != subscriptionPrice,
            "Nothing to update"
        );
        if (keccak256(_title) != keccak256(title)) title = _title;
        if (keccak256(_description) != keccak256(description)) description = _description;
        if (_subscriptionPrice == subscriptionPrice) subscriptionPrice = _subscriptionPrice;
        emit channelUpdated(address(this));
    }

    function getBalance() isOwner external view returns (uint256) {
        return address(this).balance;
    }
    
    function getPost(uint256 postId) external view returns (Post memory) {
        uint256 globalId = indexes[postId];
        return bulletStorage.getPost(globalId);
    }

    function getLatest(uint8 size) external view returns (Post[] memory) {
        if (indexes.length == 0) return new Post[](0);
        if (size >= indexes.length) return bulletStorage.getPosts(indexes);
        uint256 oldest = indexes.length - size;
        uint256[] memory resultIndexes = new uint256[](size);
        for (uint256 i = oldest; i <= indexes.length - 1; i++)  resultIndexes[i - oldest] = indexes[i];
        return bulletStorage.getPosts(resultIndexes);
    }

    function getAfter(uint256 offset, uint256 size) external view returns (Post[] memory) {
        if (indexes.length == 0) return new Post[](0); 
        uint256 lastIndex = indexes.length - 1;
        if (offset + 1 >= lastIndex) return new Post[](0);
        uint256 oldest = offset + 1;
        uint256 newest = offset + size;
        if (newest > lastIndex) return new Post[](0);
        uint256[] memory result = new uint256[](newest - oldest + 1);
        for (uint256 i = oldest; i <= newest; i++) result[i - oldest] = indexes[i];
        return bulletStorage.getPosts(result);
    }

    function getBefore(uint256 offset, uint256 size) external view returns (Post[] memory) {
        if (indexes.length == 0) return new Post[](0); 
        uint256 lastIndex = indexes.length - 1;
        uint256 oldest = offset < size ? 0: offset - size;
        if (oldest > lastIndex) return new Post[](0);
        uint256 newest = offset > lastIndex ? lastIndex: offset;
        uint256[] memory result = new uint256[](newest - oldest + 1);
        for (uint256 i = oldest; i <= newest; i++) result[i - oldest] = indexes[i];
        return bulletStorage.getPosts(result);
    }

}