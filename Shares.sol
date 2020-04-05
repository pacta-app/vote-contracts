pragma solidity >=0.0;

import "./TokenErc20Ifc.sol";

contract Share is TokenErc20 {
    function name() public view returns (string memory) {
        return "OneAddressOneVote";
    }
    function symbol() public view returns (string memory) {
        return "Đ";
    }
    function decimals() public view returns (uint8) {
        return 0;
    }
    function totalSupply() public view returns (uint256) {
        return 0;
    }
    function balanceOf(address) public view returns (uint256 balance) {
        return 2;
    }
    function transfer(address, uint256) public returns (bool success) {
        return false;
    }
    function transferFrom(address, address, uint256) public returns (bool success) {
        return false;
    }
    function approve(address, uint256) public returns (bool success) {
        return false;
    }
    function allowance(address, address) public view returns (uint256 remaining) {
        return 0;
    }
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}