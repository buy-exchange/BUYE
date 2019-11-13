pragma solidity ^0.5.10;

import "./Ownable.sol";
import "./LibSafeMath.sol";
import "./IERC20.sol";

/**
 * @title Standard Token Contract
 * @dev implements of {ERC20} Token
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based oncode By Tether(https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7#code)
 */
 
contract StandardToken is Ownable, IERC20 {
    using SafeMath for uint256;
    
    uint256 internal _totalSupply;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowed;
    
    uint256 private MAX_ALLOWED_UINT = 2 ** 256 - 1;
    
    uint256 internal basisPointRate = 0;
    uint256 internal maximumFee = 0;
    
    /**
     * @dev Fix for the {ERC20} short address attack
     */
    modifier onlyPayloadSize(uint256 size) {
        require(!(msg.data.length < size + 4));
        _;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address _account) public view returns(uint256) {
        return _balances[_account];
    }
    
    function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool) {
        uint256 fee = (_value.mul(basisPointRate)).div(10000);
        
        if(fee > maximumFee) { fee = maximumFee; }
        
        uint256 sendAmount = _value.sub(fee);
        
        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(sendAmount);
        
        if(fee > 0) {
            _balances[_owner] = _balances[_owner].add(fee);
            emit Transfer(msg.sender, _owner, fee);
        }
        
        emit Transfer(msg.sender, _to, sendAmount);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3 * 32) returns (bool) {
        uint256 _allowance = _allowed[_from][msg.sender];
        
        uint256 fee = (_value.mul(basisPointRate)).div(10000);
        
        if (fee > maximumFee) { fee = maximumFee; }
        
        if (_allowance < MAX_ALLOWED_UINT) {
            _allowed[_from][msg.sender] = _allowance.sub(_value);
        }
        
        uint256 sendAmount = _value.sub(fee);
        
        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(sendAmount);
        
        if(fee >0) {
            _balances[_owner] = _balances[_owner].add(fee);
            emit Transfer(_from, _owner, fee);
        }
        
        emit Transfer(_from, _to, sendAmount);
        return true;
    }
    
    function allowance(address _tokenOwner, address _tokenSpender) public view returns (uint256) {
        return _allowed[_tokenOwner][_tokenSpender];
    }
    
    function approve(address _spender, uint256 _amount) public onlyPayloadSize(2 * 32) returns (bool) {
        /**
         * @dev consider error case
         * @dev https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
         */
        require(!((_amount != 0) && (_allowed[msg.sender][_spender] != 0 )), "StandardToken : allowance is Not Zero and amount is Not Zero");
        
        _allowed[msg.sender][_spender] = _amount;
        
        emit Approval(msg.sender, _spender, _amount);
        
        return true;
    }
}

/**
 * @title Legacy Token Interface
 * @dev Legacy function
 */
contract UpgradedToken is StandardToken {
    /**
     * @dev called by the legacy contract
     * @dev ensure msg.sender to be the contract address
     */
    function transferByLegacy(address _from, address _to, uint256 _amount) public returns (bool);
    function transferFromByLegacy(address _sender, address _from, address _to, uint256 _amount) public returns (bool);
    function approveByLegacy(address _from, address _spender, uint256 _value) public returns (bool);
}