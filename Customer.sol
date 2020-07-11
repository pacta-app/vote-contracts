pragma solidity >=0.0;

import "./owned.sol";
import "./signed.sol";
import "./LibCustomer.sol";
import "./CustomerIfc.sol";

contract Customer is CustomerIfc, owned, signed {
    string private name;
    uint256 private paidShareholders;
    address[] private assemblies;

    modifier fromassembly {
        bool verified = false;
        for (uint256 i = 0; i < assemblies.length; ++i) {
            if (msg.sender == address(assemblies[i])) {
                verified = true;
                break;
            }
        }
        require(verified, "consumation is only allowed from own assembly");
        _;
    }

    constructor(string memory _name, address _signatory)
        public
        signed(_signatory)
    {
        name = _name;
    }

    function getName() public view restrict returns (string memory) {
        return name;
    }

    function getPaidShareholders() public view restrict returns (uint256) {
        return paidShareholders;
    }

    function getAssemblies() public view restrict returns (address[] memory) {
        return assemblies;
    }

    function rename(
        string memory _name,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict issigned(abi.encode(_name, address(this)), v, r, s) {
        name = _name;
    }

    function newAssembly(
        string memory _name,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict issigned(abi.encode(_name, address(this)), v, r, s) {
        require(paidShareholders > 0, "payment required");
        owned a = LibCustomer.newAssembly(_name, this, signatory);
        a.changeOwner(owner);
        assemblies.push(address(a));
    }

    function payment(uint256 _amount) public restrict {
        paidShareholders += _amount;
    }

    function consume(uint256 _amount) public fromassembly {
        paidShareholders -= _amount;
    }
}
