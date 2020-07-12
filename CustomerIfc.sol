pragma solidity >=0.0;

interface CustomerIfc {
    function consume(uint256 _amount, uint256 _assemblyId) external;
}
