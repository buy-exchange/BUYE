pragma solidity ^0.5.15;

import "./Ownable.sol";

/**
 * @title ReceiveLimiter
 * @author Yoonsung
 * @notice This contract acts as an ERC20 extension. It must
 * be called from the creator of the ERC20, and a modifier is
 * provided that can be used together. This contract is short-lived.
 * You cannot re-enable it after ReceiveUnlock, to be careful. Provides 
 * a set of functions to manage the addresses that can be sent.
 */
contract ReceiveLimiter is Ownable {
    event ReceiveWhitelisted(address dsc);
    event ReceiveDelisted(address dsc);
    event ReceiveUnlocked();

    bool public receiveLimit;
    mapping(address => bool) public receiveWhitelist;

    /**
    * @notice In constructor, Set Receive Limit exceptionally msg.sender.
    * constructor is used, the restriction is activated.
    */
    constructor() public {
        receiveLimit = true;
        receiveWhitelist[msg.sender] = true;
    }

    modifier isAllowedReceive(address dsc) {
        if (receiveLimit)
            require(receiveWhitelist[dsc], "Limiter/Not-Allow-Address");
        _;
    }

    /**
    * @notice Register the address that you want to allow to be receive.
    * @param _whiteAddress address The specify what to receive target.
    */
    function addAllowReceiver(address _whiteAddress) public onlyOwner {
        require(_whiteAddress != address(0), "Limiter/Not-Allow-Zero-Address");
        receiveWhitelist[_whiteAddress] = true;
        emit ReceiveWhitelisted(_whiteAddress);
    }

    /**
    * @notice Register the addresses that you want to allow to be receive.
    * @param _whiteAddresses address[] The specify what to receive target.
    */
    function addAllowReceivers(address[] memory _whiteAddresses)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _whiteAddresses.length; i++) {
            addAllowReceiver(_whiteAddresses[i]);
        }
    }

    /**
    * @notice Remove the address that you want to allow to be receive.
    * @param _whiteAddress address The specify what to receive target.
    */
    function removeAllowedReceiver(address _whiteAddress) public onlyOwner {
        require(_whiteAddress != address(0), "Limiter/Not-Allow-Zero-Address");
        delete receiveWhitelist[_whiteAddress];
        emit ReceiveDelisted(_whiteAddress);
    }

    /**
    * @notice Remove the addresses that you want to allow to be receive.
    * @param _whiteAddresses address[] The specify what to receive target.
    */
    function removeAllowedReceivers(address[] memory _whiteAddresses)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _whiteAddresses.length; i++) {
            removeAllowedReceiver(_whiteAddresses[i]);
        }
    }

    /**
    * @notice Revoke Receive restrictions.
    */
    function receiveUnlock() external onlyOwner {
        receiveLimit = false;
        emit ReceiveUnlocked();
    }
}
