pragma solidity ^0.5.10;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and basic authorization
 */
 
 contract Ownable {
     address internal _owner;
     
     constructor () internal {
        _owner = msg.sender;
     }
     
    function isOwner() internal view returns(bool) {
        return msg.sender == _owner;
    }
     
     modifier onlyOwner() {
         require(isOwner(), "Ownable : sender is not **Owner**");
         _;
     }
 }