pragma solidity >=0.0;

import "./owned.sol";
import "./signed.sol";
import "./LibAssembly.sol";
import "./CustomerIfc.sol";

contract Assembly is owned, signed {
    using LibAssembly for LibAssembly.Data;
    LibAssembly.Data private data;

    constructor(
        string memory _identifier,
        uint256 _assemblyId,
        CustomerIfc _customer,
        address _signatory
    ) public signed(_signatory) {
        data.construct(_identifier, _assemblyId, _customer);
    }

    // getter

    function registrations(string memory s) public view returns (address) {
        return data.registrations[s];
    }

    function shareholders(address a) public view returns (string memory) {
        return data.shareholders[a];
    }

    function secrets(uint256 i) public view returns (string memory) {
        return data.secrets[i];
    }

    function votings(uint256 i) public view returns (address) {
        return data.votings[i];
    }

    function numSecrets() public view returns (uint256) {
        return data.secrets.length;
    }

    function numVotings() public view returns (uint256) {
        return data.votings.length;
    }

    // shareholder's access, security by signed messages

    function register(
        string memory secret,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict {
        data.register(secret, address(this), v, r, s);
    }

    // administration, restricted to assembly owner

    function setShareholder(
        address shareholder,
        uint256 votes,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        restrict
        issigned(abi.encode(shareholder, votes, address(this)), v, r, s)
    {
        data.setShareholder(shareholder, votes);
    }

    function setShareholders(
        address[] memory shareholder,
        uint256[] memory votes,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        restrict
        issigned(abi.encode(shareholder, votes, address(this)), v, r, s)
    {
        data.setShareholders(shareholder, votes);
    }

    function newVoting(
        string memory title,
        string memory proposal,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        restrict
        issigned(abi.encode(title, proposal, address(this)), v, r, s)
    {
        data.newVoting(title, proposal, signatory, owner);
    }

    function lock(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict issigned(abi.encode(address(this)), v, r, s) {
        data.lock();
    }
}
