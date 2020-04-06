pragma solidity >=0.0;

import "./owned.sol";

contract Assembly is owned {

    mapping(string => address) public registrations; // users that registered, maps secret to address
    mapping(address => string) public shareholders; // list of registered shareholders
    string[] public secrets; // list of registered secrets
    address public api; // address of the api's contratcs
    address[] public votings; // list of votings

    constructor(address _api) public {
        api = _api;
    }

    function register(string memory secret, uint8 v, bytes32 r, bytes32 s) public {
        require(msg.sender==api, "only the API is allowed to register");
        // reg is a signed message
        // extract signer's address and the shared secret
        // set registered and index
        bytes32 h = sha256(bytes(secret));
        address shareholder = ecrecover(h, v, r, s);
        require(shareholder!=address(0x0), "identification failed due to invalid signature");
        require(registrations[secret]==address(0x0), "secret has already been used");
        require(bytes(shareholders[shareholder]).length==0, "you are already registered");
        registrations[secret] = shareholder;
        shareholders[shareholder] = secret;
        secrets.push(secret);
    }

    function addVoting(address voting) public restrict {
        votings.push(voting);
    }

}