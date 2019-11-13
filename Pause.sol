pragma solidity ^0.5.10;

import "./LibRoles.sol";
import "./Ownable.sol";

/**
 * @title PauserRole
 * @dev Minter Permissions
 * @dev based openzeppelin-contracts/access/Roles/Mint(https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/roles/PauserRole.sol)
 */ 

contract PauserRole is Ownable {
    using Roles for Roles.Role;
    
    event PauserAdd(address indexed account);
    event PauserRemove(address indexed account);
    
    Roles.Role private _pauser;
    
    constructor () internal {
        _addPauser(msg.sender);
    }
    
    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }
    
    function isPauser(address _account) public view returns (bool) {
        return _pauser.has(_account);
    }
    
    function _addPauser(address _account) internal {
        _pauser.add(_account);
        emit PauserAdd(_account);
    }
    
    function _removePauser(address _account) internal {
        _pauser.remove(_account);
        emit PauserRemove(_account);
    }
    
    /**
     * @dev Pause Rule Add, require Pause Permission
     */
     function addPauser(address _account) public onlyOwner {
         _addPauser(_account);
     }
     
     /**
      * @dev Pause Role Remove, require Pause Permission
      */ 
      function removePauser(address _account) public onlyOwner {
          _removePauser(_account);
      }
}

/**
 * @title Pausable
 * @dev  Pausable Function Implements
 */

contract Pausable is PauserRole {
    event Paused();
    event Unpaused();
    
    bool private _paused;
    
    constructor () internal {
        _paused = false;
    }
    
    function paused() public view returns (bool) {
        return _paused;
    }
    
    modifier whenNotPaused() {
        require(!_paused, "Pausable : paused");
        _;
    }
    
    modifier whenPaused() {
        require(_paused, "Pausable : not paused");
        _;
    }
    
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused();
    }
    
    function unpause() public onlyPauser whenPaused{
        _paused = false;
        emit Unpaused();
    }
}