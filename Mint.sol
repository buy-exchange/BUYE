pragma solidity ^0.5.10;

import "./LibRoles.sol";
import "./Ownable.sol";

/**
 * @title MinterRole
 * @dev Minter Permissions
 * @dev based openzeppelin-contracts/access/Roles/Mint(https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/roles/MinterRole.sol)
 * @dev Minter != Owner
 */ 

contract MinterRole is Ownable {
    using Roles for Roles.Role;
    
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    
    Roles.Role private _minter;
    
    constructor () internal {
        _addMinter(msg.sender);
    }
    
    modifier onlyMinter() {
        require(isMinter(msg.sender), "Minter : Caller does not have minter Role");
        _;
    }
    
    function isMinter(address _account) public view returns(bool) {
        return _minter.has(_account);
    }
    
    function _addMinter(address _account) internal {
        _minter.add(_account);
        emit MinterAdded(_account);
    }
    
    function _removeMinter(address _account) internal {
        _minter.remove(_account);
        emit MinterRemoved(_account);
    }
    
    /**
     * @dev minter role account add, require minter permissions
     */ 
    function addMinter(address _account) public onlyOwner {
        _addMinter(_account);
    }
    
    /**
     * @dev minter role account remove, require minter permissions
     */
    function removeMinter(address _account) public onlyOwner {
        _removeMinter(_account);
    }
}