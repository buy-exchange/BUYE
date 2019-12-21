pragma solidity ^0.5.15;

import "./Ownable.sol";

/**
 * @title Freezer
 * @author Yoonsung
 * @notice This Contracts is an extension of the ERC20. Transfer
 * of a specific address can be blocked from by the Owner of the
 * Token Contract.
 */
contract Freezer is Ownable {
    event Freezed(address dsc);
    event Unfreezed(address dsc);

    mapping(address => bool) public freezing;

    modifier isFreezed(address src) {
        require(freezing[src] == false, "Freeze/Fronzen-Account");
        _;
    }

    /**
    * @notice The Freeze function sets the transfer limit
    * for a specific address.
    * @param _dsc address The specify address want to limit the transfer.
    */
    function freeze(address _dsc) external onlyOwner {
        require(_dsc != address(0), "Freeze/Zero-Address");
        require(freezing[_dsc] == false, "Freeze/Already-Freezed");

        freezing[_dsc] = true;

        emit Freezed(_dsc);
    }

    /**
    * @notice The Freeze function removes the transfer limit
    * for a specific address.
    * @param _dsc address The specify address want to remove the transfer.
    */
    function unFreeze(address _dsc) external onlyOwner {
        require(freezing[_dsc] == true, "Freeze/Already-Unfreezed");

        delete freezing[_dsc];

        emit Unfreezed(_dsc);
    }
}
