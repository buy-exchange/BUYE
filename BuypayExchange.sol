pragma solidity ^0.5.10;

import "./StandardToken.sol";
import "./Pause.sol";
import "./Mint.sol";
import "./BlackList.sol";
import "./Ownable.sol";

/**
 * @title BuyPAY Exchange Token 
 * @dev Inheritance Ownable, MinterRole, Pausable, StandardToken, BlackList;
 * @dev Submiited for verification at 2019-10-08
 * @dev update at 2019-11-13
 */


contract BuyPayExchangeToken is Ownable, MinterRole, Pausable, BlackRole, StandardToken, BlackList {
    string public name;
    string public symbol;
    string public desc;
    
    uint256 public decimals;
    
    address public upgradedAddress;
    
    bool private deprecated;
    
    /**
     * @dev constructor inital value
     * @dev All token are deposited to the owner's address
     * 
     * @param _initialSupply Initial Supply of the this contract
     * @param _name Token Name
     * @param _symbol Token symbol
     * @param _desc Token Description
     * @param _decimals Token Decimals
     */
    constructor (uint256 _initialSupply, string memory _name, string memory _symbol, string memory _desc, uint256 _decimals) public {
        _totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        desc = _desc;
        decimals = _decimals;
        _balances[_owner] = _initialSupply;
        deprecated = false;
    }
    
    function totalSupply() public view returns (uint256) {
        if (deprecated) {
            return StandardToken(upgradedAddress).totalSupply();
        } else {
            return super.totalSupply();
        }
    }
    
    function balanceOf(address _account) public view returns (uint256) {
        if (deprecated) {
            return StandardToken(upgradedAddress).balanceOf(_account);
        } else {
            return super.balanceOf(_account);
        }
    }
    
    function transfer(address _to, uint256 _amount) public whenNotPaused returns (bool) {
        require(!isBlackListed[msg.sender], "BuyPayExchangeToken : Sender is BlackList");
        
        if (deprecated) {
            return UpgradedToken(upgradedAddress).transferByLegacy(msg.sender, _to, _amount);
        } else {
            return super.transfer(_to, _amount);
        }
    }
    
    function transferFrom(address _from, address _to, uint256 _amount) public whenNotPaused returns (bool) {
        require(!isBlackListed[msg.sender], "BuyPayExchangeToken : Sender is BlackList");
        
        if (deprecated) {
            return UpgradedToken(upgradedAddress).transferFromByLegacy(msg.sender, _from, _to, _amount);
        } else {
            return super.transferFrom(_from, _to, _amount);
        }
    }
    
    function approve(address _spender, uint256 _amount) public returns (bool) {
        if (deprecated) {
            return UpgradedToken(upgradedAddress).approveByLegacy(msg.sender, _spender, _amount);
        } else {
            return super.approve(_spender, _amount);
        }
    }
    
    function allowance(address _tokenOwner, address _tokenSpender) public view returns (uint256) {
        if (deprecated) {
            return StandardToken(upgradedAddress).allowance(_tokenOwner, _tokenSpender);
        } else {
            return super.allowance(_tokenOwner, _tokenSpender);
        }
    }
    
    /**
     * @dev this contract is deprecate
     */
    function deprecate(address _upgradedAddress) public onlyOwner {
        deprecated = true ;
        upgradedAddress = _upgradedAddress;
        emit Deprecate(_upgradedAddress);
    }
    
    /**
     * @dev set Fee, Not Ethereum Gas!
     * @dev BasisPoint is ratio and new MaxFee is Amount
     * @dev if fee (calculated BasisPoint) over maximumFee, fee is maximumFee implements
     */
    function setFeeRate(uint256 newBasisPoints, uint256 newMaxFee) public onlyOwner {
        require(newBasisPoints < 20 , "BuyPayExchangeToken : BasisPoint is Bigger");
        require(newMaxFee < 50, "BuyPayExchangeToken : MaxFee is Bigger");
        
        basisPointRate = newBasisPoints;
        maximumFee = newMaxFee.mul(10 ** decimals);
        
        emit FeeRate(newBasisPoints, newMaxFee);
    }
    
    /**
     * @dev get Fee, Not Ethereum Gas!
     * @dev returns Current Fee Rate and maximumFee
     */
     function getFeeRate() public view returns (uint256, uint256) {
         return ( basisPointRate, maximumFee);
     }
    
    /**
     * @dev Extension of {ERC20} 
     * @dev deposited into the owner's address
     * @param _amount Number of tokens to be mint
     */
    function mint(uint256 _amount) public onlyMinter {
        require(_totalSupply + _amount > _totalSupply, "BuyPayExchangeToken : incresess Token Fail(TotalSupply)");
        require(_balances[_owner] + _amount > _balances[_owner], "BuyPayExchangeToken :incresess Token Fail (Hold Amount) ");
        
        _balances[_owner] = _balances[_owner].add(_amount);
        _totalSupply =  _totalSupply.add(_amount);
        
        emit Mint(_amount);
    }
    
    /**
     * @dev Extension of {ERC20}
     * @dev withdrawn from owner's address
     * @dev _amount Number of tokens to be burn
     */
    
    function burn(uint256 _amount) public onlyMinter {
        require(_totalSupply >= _amount, "BuyPayExchangeToken : amount is Over TotalSupply");
        require(_balances[_owner] >= _amount, "BuyPayExchangeToken : Amount greater than the token held by the owner");
        
        _totalSupply = _totalSupply.sub(_amount);
        _balances[_owner] = _balances[_owner].sub(_amount);
        
        emit Burn(_amount);
    }
    
    event Mint(uint256 amount);
    event Burn(uint256 amount);
    
    event Deprecate(address newAddress);
    event FeeRate(uint256 feeBasisPoints, uint256 maxFee);
}