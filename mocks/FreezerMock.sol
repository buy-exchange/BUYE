pragma solidity ^0.5.15;

import "../Library/Freezer.sol";

contract FreezerMock is Freezer {
    function isFreezedMock(address src) public isFreezed(src) returns (bool) {
        return true;
    }
}
