pragma solidity >=0.0;

import "./owned.sol";
import "./signed.sol";
import "./Assembly.sol";

contract Customer is owned, signed {
    string private name;
    uint256 private paidShareholders;
    Assembly[] private assemblies;

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

    function getAssemblies() public view restrict returns (Assembly[] memory) {
        return assemblies;
    }

    event renamed(string, string);

    function rename(
        string memory _name,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict issigned(_name, v, r, s) {
        emit renamed(name, _name);
        name = _name;
    }

    event assemblyCreated(Assembly, string);

    function newAssembly(
        string memory _name,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict issigned(_name, v, r, s) {
        require(paidShareholders > 0, "payment required");
        Assembly a = new Assembly(_name, this);
        a.changeOwner(owner);
        assemblies.push(a);
        emit assemblyCreated(a, _name);
    }

    function payment(uint256 _amount) public restrict {
        paidShareholders += _amount;
    }

    function consume(uint256 _amount) public fromassembly {
        paidShareholders -= _amount;
    }
}
