pragma solidity >=0.0;

import "./owned.sol";
import "./libsign.sol";
import "./Customer.sol";

// analysis:
// abi.encode(string, uint256, address) costs ~0.0007 ether
// abi.encodePacked(string, uint256, address) costs ~0.002 ether

contract PactaVote is owned {
    mapping(address => Customer) public customers;

    constructor(address payable _owner) public {
        owner = _owner;
    }

    function finalize() public restrict {
        selfdestruct(owner);
    }

    function register(
        string memory name,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict {
        address sender = libsign.verify(
            abi.encode(name, address(this)),
            v,
            r,
            s
        );
        require(
            address(customers[sender]) == address(0x0),
            "customer already exists"
        );
        Customer c = new Customer(name, sender);
        c.changeOwner(owner);
        customers[sender] = c;
    }

    function remove(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict {
        address sender = libsign.verify(abi.encode(address(this)), v, r, s);
        require(
            address(customers[sender]) != address(0x0),
            "customer does not exists"
        );
        delete customers[sender];
    }
}
