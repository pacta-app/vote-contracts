pragma solidity >=0.0;

import "./owned.sol";
import "./Assembly.sol";
import "./Customer.sol";

library LibCustomer {
    function newAssembly(
        string memory _name,
        Customer _customer,
        address _signatory
    ) public returns (owned) {
        return owned(new Assembly(_name, _customer, _signatory));
    }
}
