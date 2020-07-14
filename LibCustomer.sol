pragma solidity >=0.0;

import "./owned.sol";
import "./Assembly.sol";
import "./Customer.sol";

library LibCustomer {
    struct Data {
        string name;
        uint256 paidShareholders;
        address[] assemblies;
    }

    function newAssembly(
        Data storage data,
        string memory _name,
        Customer _customer,
        address payable _owner,
        address _signatory
    ) public returns (address) {
        require(data.paidShareholders > 0, "payment required");
        owned a = new Assembly(
            _name,
            data.assemblies.length,
            _customer,
            _signatory
        );
        a.changeOwner(_owner);
        data.assemblies.push(address(a));
        return address(a);
    }
}
