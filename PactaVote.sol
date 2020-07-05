pragma solidity >=0.0;

import "./owned.sol";
import "./libsign.sol";
import "./Customer.sol";

contract PactaVote is owned {
    mapping(address => Customer) public customers;

    constructor(address payable _owner) public {
        owner = _owner;
    }

    function finalize() public restrict {
        selfdestruct(owner);
    }

    event registered(address, Customer, string);

    function register(
        string memory name,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict returns (address sender, Customer c) {
        sender = libsign.verify(name, v, r, s);
        require(
            address(customers[sender]) == address(0x0),
            "customer already exists"
        );
        c = new Customer(name, sender);
        c.changeOwner(owner);
        customers[sender] = c;
        emit registered(sender, c, name);
    }

    event removed(address, string);

    function remove(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict returns (address sender, Customer c) {
        sender = libsign.verify("REMOVE", v, r, s);
        c = customers[sender];
        string memory name = c.name();
        require(address(c) != address(0x0), "customer does not exists");
        delete c;
        emit removed(sender, name);
    }
}
