pragma solidity >=0.0;

import "./TokenErc20Ifc.sol";
import "./owned.sol";

contract Shares is TokenErc20, owned {
    mapping(address => uint256) shareholders;
    uint256 total = 0;
    bool public locked = false; // lock before assembly starts

    modifier open {
        require(!locked, "configuration is already locked");
        _;
    }

    function setShareholder(address shareholder, uint256 votes)
        public
        open
        restrict
    {
        total = total + votes - shareholders[shareholder]; // remove previous add current
        shareholders[shareholder] = votes;
    }

    function setShareholders(
        address[] memory shareholder,
        uint256[] memory votes
    ) public open restrict {
        require(shareholder.length == votes.length, "array size missmatch");
        for (uint256 i = 0; i < votes.length; ++i) {
            total = total + votes[i] - shareholders[shareholder[i]]; // remove previous add current
            shareholders[shareholder[i]] = votes[i];
        }
    }

    function lock() public open restrict {
        locked = true;
    }

    function name() public view returns (string memory) {
        return "Shareholder Management";
    }

    function symbol() public view returns (string memory) {
        return "$h";
    }

    function decimals() public view returns (uint8) {
        return 0;
    }

    function totalSupply() public view returns (uint256) {
        return total;
    }

    function balanceOf(address shareholder)
        public
        view
        returns (uint256 balance)
    {
        return shareholders[shareholder];
    }

    function transfer(address, uint256) public returns (bool success) {
        return false;
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public returns (bool success) {
        return false;
    }

    function approve(address, uint256) public returns (bool success) {
        return false;
    }

    function allowance(address, address)
        public
        view
        returns (uint256 remaining)
    {
        return 0;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}
