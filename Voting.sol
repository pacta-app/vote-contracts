pragma solidity >=0.0;

import "./owned.sol";
import "./TokenErc20Ifc.sol";

contract Voting is owned {
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
      if (starttime==0&&endtime>0) {
        starttime = now;
        endtime += starttime;
      }
      require(endtime!=0, "endttime is not defined");
      require(starttime!=0, "startime is not defined");
      require(endtime>starttime, "endttime is not after starttime");
      require(starttime>=now, "start time must be in the future");
      require(voting.starttime==0&&voting.endtime==0, "time is already configured");
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
    function canVote(address sender) public view returns(bool) {
        return !closed()&&!voting.voters[sender];
    }
    function addressToBytes(address a) internal pure returns (bytes memory) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
          b[i] = byte(uint8(uint(a) / (2**(8*(19 - i)))));
        return b;
    }
    function test(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public view returns(bytes32 calculatedHash, bytes memory message, address shareholder, uint256 shares) {
        message = abi.encodePacked("TEST on ", addressToBytes(address(this)));
        calculatedHash = keccak256(message);
        shareholder = ecrecover(hash, v, r, s);
        shares = voting.tokenErc20.balanceOf(shareholder);
    }
    function voteYes(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public returns(bytes memory message, address shareholder, uint256 shares) {
        require(!closed(), "voting is already closed");
        require(started(), "voting is not yet started");
        message = abi.encodePacked("YES on ", addressToBytes(address(this)));
        require(hash == keccak256(message), "wrong hash value sent");
        shareholder = ecrecover(hash, v, r, s);
        require(shareholder!=address(0x0), "identification failed due to invalid signature");
        require(!voting.voters[shareholder], "already voted");
        shares = voting.tokenErc20.balanceOf(shareholder);
        require(shares>0, "not a validated shareholder");
        voting.voters[shareholder] = true;
        voting.aye+=shares;
    }
    function voteNo(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public returns(bytes memory message, address shareholder, uint256 shares) {
        require(!closed(), "voting is already closed");
        require(started(), "voting is not yet started");
        message = abi.encodePacked("NO on ", addressToBytes(address(this)));
        require(hash == keccak256(message), "wrong hash value sent");
        shareholder = ecrecover(hash, v, r, s);
        require(shareholder!=address(0x0), "identification failed due to invalid signature");
        require(!voting.voters[shareholder], "already voted");
        shares = voting.tokenErc20.balanceOf(shareholder);
        require(shares>0, "not a validated shareholder");
        voting.voters[shareholder] = true;
        voting.nay+=shares;
    }
}
