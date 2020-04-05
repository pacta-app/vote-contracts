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

    function register(string memory reg) public {
        require(msg.sender==api, "only the API is allowed to register");
        // reg is a signed message
        // extract signer's address and the shared secret
        // set registered and index
        index.push(reg); // todo fix
    }

    function addVoting(address voting) public restrict {
        votings.push(voting);
    }

}