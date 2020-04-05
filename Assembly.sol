pragma solidity >=0.0;

import "./owned.sol";

contract Assembly is owned {

    mapping(string => address) public registered; // users that registered, maps secret to address
    string[] public index; // list of registered secrets
    address public api; // address of the api's contratcs
    address[] public votings; // list of votings

    constructor(address _api) public {
        api = _api;
    }

    function register(string memory secret, uint8 v, bytes32 r, bytes32 s) public returns(address) {
        require(msg.sender==api, "only the API is allowed to register");
        // reg is a signed message
        // extract signer's address and the shared secret
        // set registered and index
        bytes32 h = sha256(bytes(secret));
        address shareholder = ecrecover(h, v, r, s);
        require(registered[secret]==address(0x0), "already registered");
        require(shareholder!=address(0x0), "invalid signature");
        registered[secret] = shareholder;
        index.push(secret);
        return shareholder;
    }

    function addVoting(address voting) public restrict {
        votings.push(voting);
    }

}