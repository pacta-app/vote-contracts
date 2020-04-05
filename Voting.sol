pragma solidity >=0.0;

import "./owned.sol";
import "./TokenErc20Ifc.sol";

contract Voting is owned {
    //using VotingLib for VotingLib.Voting;
    //VotingLib.Voting private voting;
    struct Data {
        string title;
        string proposal;
        uint256 starttime;
        uint256 endtime;
        uint256 aye;
        uint256 nay;
        TokenErc20 tokenErc20;
        mapping(address => bool) voters;
    }
    Data internal voting;
    modifier isclosed {
      require(closed(), "voting not yet closed");
      _;
    }
    constructor(string memory t, string memory p, TokenErc20 token) public {
      require(bytes(t).length>0, "voting title is required");
      require(bytes(p).length>0, "voting proposal is required");
      voting.title = t;
      voting.proposal = p;
      voting.starttime = 0;
      voting.endtime = 0;
      voting.tokenErc20 = token;
    }
    function setVotingTime(uint256 starttime, uint256 endtime) public restrict {
      voting.starttime = starttime;
      voting.endtime = endtime;
    }
    function title() public view returns(string memory) {
      return voting.title;
    }
    function proposal() public view returns(string memory) {
      return voting.proposal;
    }
    function starttime() public view returns(uint256) {
      return voting.starttime;
    }
    function endtime() public view returns(uint256) {
      return voting.endtime;
    }
    function aye() public view isclosed returns(uint256) {
      return voting.aye;
    }
    function nay() public view isclosed returns(uint256) {
      return voting.nay;
    }
    function tokenErc20() public view returns(TokenErc20) {
      return voting.tokenErc20;
    }
    function voters(address i) public view returns(bool) {
        return voting.voters[i];
    }
    function resolution() public view isclosed returns(bool, uint256, string memory, string memory) {
        return (accepted(), voting.endtime, voting.title, voting.proposal);
    }
    function closed() public view returns(bool) {
        return voting.starttime>0 && voting.endtime>0 && now>voting.endtime;
    }
    function started() public view returns(bool) {
        return voting.starttime>0 && voting.endtime>0 && now>voting.starttime;
    }
    function running() public view returns(bool) {
      return started() && !closed();
    }
    function accepted() public view isclosed returns(bool) {
        return voting.aye>voting.nay;
    }
    function rejected() public view isclosed returns(bool) {
        return voting.aye<=voting.nay;
    }
    function votes() public view isclosed returns(uint256, uint256) {
        return (voting.aye, voting.nay);
    }
    function canVote() public view returns(bool) {
        return !closed()&&!voting.voters[msg.sender];
    }
    function voteYes() public returns(uint256) {
        require(!closed(), "voting is already closed");
        require(started(), "voting is not yet started");
        require(!voting.voters[msg.sender], "already voted");
        voting.voters[msg.sender] = true;
        if (voting.tokenErc20==TokenErc20(0x0)) {
            ++voting.aye;
            return 1;
        } else {
            voting.aye+=voting.tokenErc20.balanceOf(msg.sender);
            return voting.tokenErc20.balanceOf(msg.sender);
        }
    }
    function voteNo() public returns(uint256) {
        require(!closed(), "voting is already closed");
        require(started(), "voting is not yet started");
        require(!voting.voters[msg.sender], "already voted");
        voting.voters[msg.sender] = true;
        if (voting.tokenErc20==TokenErc20(0x0)) {
            ++voting.nay;
            return 1;
        } else {
            voting.nay+=voting.tokenErc20.balanceOf(msg.sender);
            return voting.tokenErc20.balanceOf(msg.sender);
        }
    }
}
