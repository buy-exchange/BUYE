pragma solidity ^0.5.15;

import "./Library/Ownable.sol";
import "./Library/IERC20.sol";
import "./Library/SafeMath.sol";
import "./Library/Freezer.sol";
import "./Library/ReceiveLimiter.sol";

/**
 * @title BuyExchange
 * @author Yoonsung
 * @notice This Contract is an implementation of BuyExchange's ERC20
 * Basic ERC20 functions and "burn" functions and "mint" are implemented. For the 
 * burn function, only the Owner of Contract can be called and used 
 * to incinerate unsold Token. mint function, only the Owner of Contract
 * can be called and Used to create a new token. LimtReceive limits are
 * imposed after the contract is distributed and can be revoked through ReceiveUnlock.
 * Don't do active again after cancellation. The Owner may also suspend the
 * transfer of a particular account at any time.
 */
contract BuyExchange is Ownable, IERC20, ReceiveLimiter, Freezer {
    using SafeMath for uint256;

    string public constant name = "BuyExchange";
    string public constant symbol = "BUYE";
    uint8 public constant decimals = 8;
    uint256 public totalSupply = 10000000e8;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    /**
    * @notice In constructor, Set Send Limit and Receive Limits.
    * Additionally, Contract's publisher is authorized to own all tokens.
    */
    constructor() public ReceiveLimiter() {
        balanceOf[msg.sender] = totalSupply;
    }

    /**
    * @notice Transfer function sends Token to the target. However,
    * caller must have more tokens than or equal to the quantity for send.
    * @param _to address The specify what to send target.
    * @param _value uint256 The amount of token to tranfer.
    * @return True if the withdrawal succeeded, otherwise revert.
    */
    function transfer(address _to, uint256 _value)
        external
        isAllowedReceive(_to)
        isFreezed(msg.sender)
        returns (bool)
    {
        require(_to != address(0), "BuyExchange/Not-Allow-Zero-Address");

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
    * @notice Transfer function sends Token to the target.
    * In most cases, the allowed caller uses this function. Send
    * Token instead of owner. Allowance address must have more
    * tokens than or equal to the quantity for send.
    * @param _from address The acoount to sender.
    * @param _to address The specify what to send target.
    * @param _value uint256 The amount of token to tranfer.
    * @return True if the withdrawal succeeded, otherwise revert.
    */
    function transferFrom(address _from, address _to, uint256 _value)
        external
        isAllowedReceive(_to)
        isFreezed(_from)
        returns (bool)
    {
        require(_from != address(0), "BuyExchange/Not-Allow-Zero-Address");
        require(_to != address(0), "BuyExchange/Not-Allow-Zero-Address");

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    /**
    * @notice The Owner of the Contracts Mint own
    * Token. can create additional tokens, with a limit of 1 trillion.
    * @param _value uint256 The amount of mint token.
    * @return True if the withdrawal succeeded, otherwise revert.
    */
    function mint(uint256 _value) external onlyOwner returns (bool) {
        require(
            totalSupply.add(_value) <= 1000000000000e8,
            "BuyExchange/Not-Allow-Mint-Limit"
        );

        balanceOf[msg.sender] = balanceOf[msg.sender].add(_value);
        totalSupply = totalSupply.add(_value);

        emit Transfer(address(0), msg.sender, _value);

        return true;
    }

    /**
    * @notice The Owner of the Contracts incinerate own
    * Token. burn unsold Token and reduce totalsupply. Caller
    * must have more tokens than or equal to the quantity for send.
    * @param _value uint256 The amount of incinerate token.
    * @return True if the withdrawal succeeded, otherwise revert.
    */
    function burn(uint256 _value) external returns (bool) {
        require(
            _value <= balanceOf[msg.sender],
            "BuyExchange/Not-Allow-Unvalued-Burn"
        );

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);

        emit Transfer(msg.sender, address(0), _value);

        return true;
    }

    /**
    * @notice Specifies the address to instead token transfer.
    * @param _spender address address to allow transfer.
    * @param _value uint256 The amount of transferable token.
    * @return True if the allowance succeeded, otherwise revert.
    */
    function approve(address _spender, uint256 _value) external returns (bool) {
        require(_spender != address(0), "BuyExchange/Not-Allow-Zero-Address");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    /**
    * @notice Specifies the address to instead token transfer
    * @param _spender address address to allow transfer.
    * @param _value uint256 The amount of increase transferable token.
    * @return True if the allowance succeeded, otherwise revert.
    */
    function increaseAllowance(address _spender, uint256 _value)
        external
        returns (bool)
    {
        require(_spender != address(0), "BuyExchange/Not-Allow-Zero-Address");
        allowance[msg.sender][_spender] = allowance[msg.sender][_spender].add(
            _value
        );
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);

        return true;
    }

    /**
    * @notice Specifies the address to instead token transfer
    * @param _spender address address to allow transfer.
    * @param _value uint256 The amount of decrease transferable token.
    * @return True if the allowance succeeded, otherwise revert.
    */
    function decreaseAllowance(address _spender, uint256 _value)
        external
        returns (bool)
    {
        require(_spender != address(0), "BuyExchange/Not-Allow-Zero-Address");
        allowance[msg.sender][_spender] = allowance[msg.sender][_spender].sub(
            _value
        );
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);

        return true;
    }
}
