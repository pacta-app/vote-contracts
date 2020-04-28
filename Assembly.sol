pragma solidity >=0.0;

import "./owned.sol";
import "./Shares.sol";
import "./VotingIfc.sol";

contract Assembly is owned {

    Shares public shares; // shareholder token
    mapping(string => address) public registrations; // users that registered, maps secret to address
    mapping(address => string) public shareholders; // list of registered shareholders
    string[] public secrets; // list of registered secrets
    address public api; // address of the api's contratcs
    address[] public votings; // list of votings
    string public identifier; // you my set any text here, e.w. th ecompany name

    constructor(string memory _identifier, address _api) public {
        identifier = _identifier;
        api = _api;
        shares = new Shares();
    }

    function numSecrets() public view returns (uint256) {
        return secrets.length;
    }

    function numVotings() public view returns (uint256) {
        return votings.length;
    }

    function verify(string memory secret, uint8 v, bytes32 r, bytes32 s) public pure returns (address sender) {
        bytes32 hash = keccak256(bytes(secret));
        sender = ecrecover(hash, v, r, s);
    }

    // shareholder's access, security by signed messages

    function register(string memory secret, uint8 v, bytes32 r, bytes32 s) public {
        //require(msg.sender==api, "only the API Server is allowed to register");
        require(bytes(secret).length>0, "not a valid secret");
        address shareholder = verify(secret, v, r, s);
        require(shareholder!=address(0x0), "identification failed due to invalid signature");
        require(registrations[secret]==address(0x0), "secret has already been used");
        require(bytes(shareholders[shareholder]).length==0, "you are already registered");
        registrations[secret] = shareholder;
        shareholders[shareholder] = secret;
        secrets.push(secret);
    }

    // administration, restricted to assembly owner
    
    function setShareholder(address shareholder, uint256 votes) public restrict {
        shares.setShareholder(shareholder, votes);
    }

    function addVoting(VotingIfc voting) public restrict {
        require(shares==voting.tokenErc20(), "wrong token in voting");
        votings.push(address(voting));
    }

    function lock() public restrict {
        shares.lock();
    }

}