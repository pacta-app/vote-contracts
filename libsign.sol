pragma solidity >=0.0;

library libsign {
    // verify sender of a signed message
    function verify(
        string memory secret,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (address sender) {
        require(bytes(secret).length > 0, "not a valid secret");
        bytes32 hash = keccak256(bytes(secret));
        sender = ecrecover(hash, v, r, s);
    }
}
