pragma solidity >=0.0;

import "./owned.sol";
import "./signed.sol";
import "./TokenErc20Ifc.sol";
import "./VotingIfc.sol";
import "./LibVoting.sol";

contract Voting is VotingIfc, owned, signed {
    using LibVoting for LibVoting.Data;
    LibVoting.Data private data;

    modifier isclosed {
        require(closed(), "voting not yet closed");
        _;
    }

    modifier isRunning {
        require(!closed(), "voting is already closed");
        require(started(), "voting is not yet started");
        _;
    }

    constructor(
        string memory title,
        string memory proposal,
        TokenErc20 token,
        address _signatory
    ) public signed(_signatory) {
        data.construct(title, proposal, token);
    }

    function setVotingTime(
        uint256 starttime,
        uint256 endtime,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        restrict
        issigned(abi.encode(starttime, endtime, address(this)), v, r, s)
    {
        data.setVotingTime(starttime, endtime);
    }

    function title() public view returns (string memory) {
        return data.title;
    }

    function proposal() public view returns (string memory) {
        return data.proposal;
    }

    function starttime() public view returns (uint256) {
        return data.starttime;
    }

    function endtime() public view returns (uint256) {
        return data.endtime;
    }

    function currenttime() public view returns (uint256) {
        return now;
    }

    function aye() public view isclosed returns (uint256) {
        return data.aye;
    }

    function nay() public view isclosed returns (uint256) {
        return data.nay;
    }

    function abstain() public view isclosed returns (uint256) {
        return data.abstain;
    }

    function standDown() public view isclosed returns (uint256) {
        return data.standDown;
    }

    function tokenErc20() public view returns (TokenErc20) {
        return data.tokenErc20;
    }

    function voters(address i) public view returns (bool) {
        return data.voters[i];
    }

    function resolution()
        public
        view
        isclosed
        returns (
            bool,
            uint256,
            string memory,
            string memory
        )
    {
        return (accepted(), data.endtime, data.title, data.proposal);
    }

    function closed() public view returns (bool) {
        return data.starttime > 0 && data.endtime > 0 && now >= data.endtime;
    }

    function started() public view returns (bool) {
        return data.starttime > 0 && data.endtime > 0 && now >= data.starttime;
    }

    function running() public view returns (bool) {
        return started() && !closed();
    }

    function accepted() public view isclosed returns (bool) {
        return data.aye > data.nay;
    }

    function rejected() public view isclosed returns (bool) {
        return data.aye <= data.nay;
    }

    function votes() public view isclosed returns (uint256, uint256) {
        return (data.aye, data.nay);
    }

    function canVote(address sender) public view returns (bool) {
        return !closed() && !data.voters[sender];
    }

    function castVote(
        LibVoting.Vote vote,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict isRunning {
        data.castVote(vote, address(this), v, r, s);
    }

    /* function voteYes(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict isRunning {
        data.voteYes(address(this), v, r, s);
    }

    function voteNo(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict isRunning {
        data.voteNo(address(this), v, r, s);
    }

    function voteAbstain(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict isRunning {
        data.voteAbstain(address(this), v, r, s);
    }

    function voteStandDown(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public restrict isRunning {
        data.voteStandDown(address(this), v, r, s);
    } */
}
