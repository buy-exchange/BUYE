pragma solidity ^0.5.10;

/**
 * @title Permission Roles Define
 * @dev based on openzeppelin-contract/access(https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Roles.sol)
 */ 
 
 library Roles {
     struct Role {
         mapping (address => bool) bearer;
     }
     
     /**
      * @dev role adding
      * 
      * @param role struct Role
      * @param account added address
      */
     function add(Role storage role, address account) internal {
         require(!has(role, account), "Roles : account already has role");
         role.bearer[account] = true;
     }
     
     /**
      * @dev role removing
      * 
      * @param role struct role
      * @param account removed address
      */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles : account does not have role");
        role.bearer[account] = false;
    }
     
    /**
     * @dev check Role
     * 
     * @param role struct role
     * @param account checking address
     */
     function has(Role storage role, address account) internal view returns (bool) {
         require(account != address(0), "Roles : account is Zero");
         return role.bearer[account];
     }
 }