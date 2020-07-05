pragma solidity >=0.0;

import "./libsign.sol";

contract signed {
    address internal signatory;

    // signatory has signed message
    modifier issigned(
        string memory secret,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) {
        verified(secret, v, r, s);
        _;
    }

    constructor(address _signatory) internal {
        signatory = _signatory;
    }

    // signatory has signed message
    function verified(
        string memory secret,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (address sender) {
        sender = libsign.verify(secret, v, r, s);
        require(
            sender == signatory,
            "access denied, you are not the contract owner"
        );
    }
}
