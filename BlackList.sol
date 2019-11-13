pragma solidity ^0.5.10;

import "./LibRoles.sol";
import "./Ownable.sol";
import "./StandardToken.sol";

/**
 * @dev BlackRole
 * @dev BlackList Managment Permission
 * @dev Based On openzeppelin-contracts/access/roles/Minter(https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/roles/MinterRole.sol)
 */
 
 contract BlackRole is Ownable {
    using Roles for Roles.Role;
     
    event BlackListManagerAdded(address indexed account);
    event BlackListManagerRemoved(address indexed account);
    
    Roles.Role private _listManager;
    
    constructor () internal {
        _addListManager(msg.sender);
    }
    
    modifier onlyListManager() {
        require(isListManager(msg.sender), "BlackRole : Caller does not have List Magagement");
        _;
    }
    
    function isListManager(address _account) public view returns (bool) {
        return _listManager.has(_account);
    }
    
    function _addListManager(address _account) internal {
        _listManager.add(_account);
        emit BlackListManagerAdded(_account);
    }
    
    function _removeListManager(address _account) internal {
        _listManager.remove(_account);
        emit BlackListManagerRemoved(_account);
    }
    
    function addListManager(address _account) public  onlyOwner {
        _addListManager(_account);
    }
    
    function removeListManager(address _account) public onlyOwner {
        _removeListManager(_account);
    }
 }
 
 /**
  * @title BlackList
  */ 
 
 contract BlackList is BlackRole, StandardToken {
     /**
      * @dev Blacklist value
      */
    mapping ( address => bool ) public isBlackListed;
    

    function addBlackList(address _evilUser) public onlyListManager {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }
    
    function removeBlackList(address _clearUser) public onlyListManager {
        isBlackListed[_clearUser] = false;
        emit RemoveBlackList(_clearUser);
    }
    
    /**
     * @dev if user is Black, user's balace is Malicious balance
     * @dev then user's balance is bunning!
     */
    function destroyBlackFund(address _user) public onlyListManager {
        require(isBlackListed[_user], "BlackList : User is Cleared User");
        
        uint256 blackFund = balanceOf(_user);
        _balances[_user] = 0;
        _totalSupply -= blackFund;
        emit DestroyBlackFund(_user, blackFund);
    }
    
    event AddedBlackList(address _user);
    event RemoveBlackList(address _user);
    event DestroyBlackFund(address _user, uint256 _balance);
}