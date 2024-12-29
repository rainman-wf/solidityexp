// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.9 <0.9.0;

import { IBulletChannel } from "contracts/IBulletChannel.sol";
import { Role } from "contracts/Role.sol";
import { Channel } from "contracts/Channel.sol";
import { Post } from "contracts/Post.sol";
import { IStorage } from "contracts/IStorage.sol";

contract BulletChannel is IBulletChannel {

    address owner;
    IStorage bulletStorage;
    bytes title;
    bytes description;
    uint256 subscriptionPrice;

    address[] subscribers;
    address[] publishers;

    mapping(address => Role) roles;

    uint256[] indexes;
    
    event postCreated(uint256 indexed globalId);
    event subscribed(address indexed channelAddress);
    event donated(address indexed channelAddress);
    event withdrawn(address indexed channelAddress);
    event channelUpdated(address indexed channelAddress);

    modifier onlyOwner() {
        require (msg.sender == owner, "No access rights");
        _;
    } 

    modifier hasReaderRights () {
        require(subscriptionPrice == 0 || (subscriptionPrice > 0 && roles[msg.sender] != Role.NONE), "No access rights");
        _;
    }

      modifier hasPubliserhRights () {
        require(roles[msg.sender] == Role.OWNER || roles[msg.sender]  == Role.PUBLISHER, "No access rights");
        _;
    }

    constructor(address _storage, bytes memory _title, bytes memory _description, uint256 _price, address _owner) {
        bulletStorage = IStorage(_storage);
        title = _title;
        description = _description;
        subscriptionPrice = _price;
        owner = _owner;
    }

    function createPost(bytes memory content, bytes8 encoding) hasPubliserhRights external {
        uint256 globalId = bulletStorage.savePost(content, address(this), encoding, getNewIndex());    
        indexes.push(globalId);
        emit postCreated(globalId);
    }

    function getNewIndex() private view returns (uint256) {
        return indexes.length;
    }

    function setRole(address user, Role role) onlyOwner external {
        if (role == Role.OWNER) owner = user;
        else roles[user] = role;
    }

    function subscribe() external payable {
        require(roles[msg.sender] == Role.NONE, "You already have role subscriber or hier");
        require(msg.value >= subscriptionPrice, "Value is too low");
        subscribers.push(msg.sender);
        roles[msg.sender] = Role.SUBSCRIBER;
        emit subscribed(address(this));
    }

    function donate() external payable {
        emit donated(address(this));
    }

    function withdraw(uint256 value) onlyOwner external {
        (bool ok, ) = msg.sender.call{ value: value }("");
        require(ok, "Transfer failed");
    }

    function getInfo() external view returns (Channel memory) {
        Role role;
        if (msg.sender == owner) role = Role.OWNER; 
        else role = roles[msg.sender];
        return Channel(title, description, address(this), subscriptionPrice, role);
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

    function getBalance() onlyOwner external view returns (uint256) {
        return address(this).balance;
    }
    
    function getSubscribers() onlyOwner external view returns (address[] memory) {
        return subscribers;
    }
    function getPublishers() onlyOwner external view returns (address[] memory) {
        return publishers;
    }

    function getPost(uint256 postId) external view returns (Post memory) {
        uint256 globalId = indexes[postId];
        return bulletStorage.getPost(globalId);
    }

    function getLatest(uint8 size) external view returns (Post[] memory) {
        if (indexes.length == 0) return new Post[](0);
        uint256 resultSize = size > indexes.length ? indexes.length : size;
        uint256[] memory resultIndexes = new uint256[](resultSize);
        uint256 oldest = indexes.length - size;
        for (uint256 i = oldest; i <= resultSize - 1; i++)  resultIndexes[i - oldest] = indexes[i];
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