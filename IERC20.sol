pragma solidity ^0.5.10;

/**
 * @title {ERC20} Interface
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    
    function balanceOf(address _account) external view returns(uint256);
    
    function transfer(address _to, uint256 amount) external returns (bool);
    
    function allowance(address _owner, address _spender) external view returns (uint256);
    
    function approve(address _spender, uint256 _amount) external returns (bool);
    
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}