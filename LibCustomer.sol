pragma solidity >=0.0;

import "./owned.sol";
import "./Assembly.sol";
import "./Customer.sol";

library LibCustomer {
    function newAssembly(
        string memory _name,
        uint256 _assemblyId,
        Customer _customer,
        address _signatory
    ) public returns (owned) {
        return owned(new Assembly(_name, _assemblyId, _customer, _signatory));
    }
}
