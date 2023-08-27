// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import {Challenge_NFT as NFT} from "../NFT/Challenge_NFT.sol";

contract Challenge_1 {
    bool public unlocked;
    address public owner;
    NFT public nft;

    struct User {
        bytes32 name;
        address sender;
        uint256 timestamp;
        uint256 id;
        uint256 attempts;
    }

    constructor(NFT _nft) {
        require(address(_nft) != address(0), "Zero address");
        nft = _nft;
        owner = msg.sender;
    }

    mapping(address => User) public users;

    function mint(bytes32 _name) external {

        User storage user = users[tx.origin];

        if(!unlocked && user.name != bytes32(0) && address(this).balance > 0) {
            unlocked = true;
        } else if(user.sender != msg.sender && unlocked) {
            user.id = nft.mint(user.sender);
            unlocked = false;
        }

        user.name = _name;
        user.sender = tx.origin;
        user.timestamp = block.timestamp;
        user.attempts++;
    }

    function setUnlocked(bool _unlocked) external {
        require(msg.sender == owner, "Not owner");
        unlocked = _unlocked;
    }
}