pragma solidity >=0.0;

import "./owned.sol";
import "./signed.sol";
import "./libsign.sol";
import "./Shares.sol";
import "./Voting.sol";
import "./Customer.sol";

contract Assembly is owned, signed {
    Shares public shares; // shareholder token
    mapping(string => address) public registrations; // users that registered, maps secret to address
    mapping(address => string) public shareholders; // list of registered shareholders
    string[] public secrets; // list of registered secrets
    address[] public votings; // list of votings
    string public identifier; // you my set any text here, e.w. th ecompany name
    Customer private customer; // customer of this assembly

    constructor(
        string memory _identifier,
        Customer _customer,
        address _signatory
    ) public signed(_signatory) {
        identifier = _identifier;
        customer = _customer;
        shares = new Shares();
    }

    function numSecrets() public view returns (uint256) {
        return secrets.length;
    }

    function numVotings() public view returns (uint256) {
        return votings.length;
    }

    // shareholder's access, security by signed messages

    function register(
        string memory secret,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict {
        address shareholder = libsign.verify(abi.encode(secret), v, r, s);
        require(
            shareholder != address(0x0),
            "identification failed due to invalid signature"
        );
        require(
            registrations[secret] == address(0x0),
            "secret has already been used"
        );
        require(
            bytes(shareholders[shareholder]).length == 0,
            "you are already registered"
        );
        registrations[secret] = shareholder;
        shareholders[shareholder] = secret;
        secrets.push(secret);
    }

    // administration, restricted to assembly owner

    function setShareholder(
        address shareholder,
        uint256 votes,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict issigned(abi.encode(shareholder, votes), v, r, s) {
        shares.setShareholder(shareholder, votes);
        customer.consume(1);
    }

    function setShareholders(
        address[] memory shareholder,
        uint256[] memory votes,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict issigned(abi.encode(shareholder, votes), v, r, s) {
        require(
            shareholder.length == votes.length,
            "number of shareholders must match number of shares"
        );
        shares.setShareholders(shareholder, votes);
        customer.consume(shareholder.length);
    }

    function newVoting(string memory title, string memory proposal)
        public
        restrict /*signed()*/
    {
        Voting v = new Voting(title, proposal, shares);
        v.changeOwner(owner);
        votings.push(address(v));
    }

    function lock() public restrict {
        shares.lock();
    }
}
