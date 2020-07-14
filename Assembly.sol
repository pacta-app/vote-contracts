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

    function shares() public view returns (address) {
        return address(data.shares);
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
        address _shareholder,
        uint256 _shares,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        restrict
        issigned(abi.encode(_shareholder, _shares, address(this)), v, r, s)
    {
        data.setShareholder(_shareholder, _shares);
    }

    function setShareholders(
        address[] memory _shareholders,
        uint256[] memory _shares,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        restrict
        issigned(abi.encode(_shareholders, _shares, address(this)), v, r, s)
    {
        data.setShareholders(_shareholders, _shares);
    }

    event votingCreated(address);

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
        emit votingCreated(data.newVoting(title, proposal, signatory, owner));
    }

    function lock(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict issigned(abi.encode(address(this)), v, r, s) {
        data.lock();
    }
}
