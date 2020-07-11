pragma solidity >=0.0;

import "./libsign.sol";
import "./Shares.sol";
import "./Voting.sol";
import "./CustomerIfc.sol";

library LibAssembly {
    struct Data {
        Shares shares; // shareholder token
        mapping(string => address) registrations; // users that registered, maps secret to address
        mapping(address => string) shareholders; // list of registered shareholders
        string[] secrets; // list of registered secrets
        address[] votings; // list of votings
        string identifier; // you may set any text here, e.w. the assembly purpose
        CustomerIfc customer; // customer of this assembly
    }

    function construct(
        Data storage data,
        string memory _identifier,
        CustomerIfc _customer
    ) public {
        data.identifier = _identifier;
        data.customer = _customer;
        data.shares = new Shares();
    }

    // shareholder's access, security by signed messages

    function register(
        Data storage data,
        string memory secret,
        address a,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        address shareholder = libsign.verify(abi.encode(secret, a), v, r, s);
        require(
            data.registrations[secret] == address(0x0),
            "secret has already been used"
        );
        require(
            bytes(data.shareholders[shareholder]).length == 0,
            "you are already registered"
        );
        data.registrations[secret] = shareholder;
        data.shareholders[shareholder] = secret;
        data.secrets.push(secret);
    }

    // administration, restricted to assembly owner

    function setShareholder(
        Data storage data,
        address shareholder,
        uint256 votes
    ) public {
        data.shares.setShareholder(shareholder, votes);
        data.customer.consume(1);
    }

    function setShareholders(
        Data storage data,
        address[] memory shareholder,
        uint256[] memory votes
    ) public {
        data.shares.setShareholders(shareholder, votes);
        data.customer.consume(shareholder.length);
    }

    function newVoting(
        Data storage data,
        string memory title,
        string memory proposal,
        address signatory,
        address payable owner
    ) public {
        Voting voting = new Voting(title, proposal, data.shares, signatory);
        voting.changeOwner(owner);
        data.votings.push(address(voting));
    }

    function lock(Data storage data) public {
        data.shares.lock();
    }
}
