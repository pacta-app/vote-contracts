pragma solidity >=0.0;

import "./owned.sol";
import "./signed.sol";
import "./LibCustomer.sol";
import "./CustomerIfc.sol";

contract Customer is CustomerIfc, owned, signed {
    using LibCustomer for LibCustomer.Data;
    LibCustomer.Data data;

    modifier fromassembly(uint256 assemblyId) {
        require(
            msg.sender == address(data.assemblies[assemblyId]),
            "consumation is only allowed from own assembly"
        );
        _;
    }

    constructor(string memory _name, address _signatory)
        public
        signed(_signatory)
    {
        data.name = _name;
    }

    function name() public view returns (string memory) {
        return data.name;
    }

    function paidShareholders() public view returns (uint256) {
        return data.paidShareholders;
    }

    function assemblies() public view returns (address[] memory) {
        return data.assemblies;
    }

    function rename(
        string memory _name,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict issigned(abi.encode(_name, address(this)), v, r, s) {
        data.name = _name;
    }

    event assemblyCreated(address);

    function newAssembly(
        string memory _name,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict issigned(abi.encode(_name, address(this)), v, r, s) {
        address a = data.newAssembly(_name, this, owner, signatory);
        emit assemblyCreated(a);
    }

    function payment(uint256 _amount) public restrict {
        data.paidShareholders += _amount;
    }

    function consume(uint256 _amount, uint256 _assemblyId)
        public
        fromassembly(_assemblyId)
    {
        data.paidShareholders -= _amount;
    }
}
