pragma solidity ^0.5.15;

import "../Library/ReceiveLimiter.sol";

contract ReceiveLimiterMock is ReceiveLimiter {
    constructor() public ReceiveLimiter() {}

    function isAllowedReceiveMock(address dsc)
        public
        isAllowedReceive(dsc)
        returns (bool)
    {
        return true;
    }
}
