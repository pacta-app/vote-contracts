pragma solidity >=0.0;

library libsign {
    // verify sender of a signed message
    function verify(
        bytes memory secret,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (address sender) {
        require(secret.length > 0, "not a valid secret");
        bytes32 hash = keccak256(secret);
        sender = ecrecover(hash, v, r, s);
        require(
            sender != address(0x0),
            "identification failed due to invalid signature"
        );
    }
}
