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

    function numSecrets() public view returns (uint256) {
        return secrets.length;
    }

    function numVotings() public view returns (uint256) {
        return votings.length;
    }
    
 /*    // Size of a word, in bytes.
    uint internal constant WORD_SIZE = 32;

    function uint2bytes(uint _i) internal pure returns (bytes memory) {
        if (_i == 0) {
            return bytes("0");
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return bstr;
    }

    function concat(bytes memory a, bytes memory b) internal pure returns (bytes memory) {
        return abi.encodePacked(a, b);
    } */

/*     function verify(string memory secret, uint8 v, bytes32 r, bytes32 s) public pure 
    returns (bytes32 hash, address sender, bytes memory package, bytes memory bsecret, bytes memory length, bytes memory prefix) {
        bsecret = bytes(secret);
        length = uint2bytes(bsecret.length);
        prefix = bytes("\x19Ethereum Signed Message:\n");
        package = abi.encodePacked(abi.encodePacked(prefix, length), bsecret);
        hash = sha3(prefix);
        sender = ecrecover(hash, v, r, s);
    } */

    function verify(string memory secret, uint8 v, bytes32 r, bytes32 s) public pure returns (address sender) {
        bytes32 hash = keccak256(bytes(secret));
        sender = ecrecover(hash, v, r, s);
    }

    function register(string memory secret, uint8 v, bytes32 r, bytes32 s) public {
        require(msg.sender==api, "only the API is allowed to register");
        address shareholder = verify(secret, v, r, s);
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