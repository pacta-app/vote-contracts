pragma solidity >=0.0;

import "./owned.sol";
import "./TokenErc20Ifc.sol";
import "./VotingIfc.sol";


contract Voting is VotingIfc, owned {
    struct Data {
        string title;
        string proposal;
        uint256 starttime;
        uint256 endtime;
        uint256 aye;
        uint256 nay;
        uint256 abstain;
        uint256 standDown;
        TokenErc20 tokenErc20;
        mapping(address => bool) voters;
    }
    Data internal voting;
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
        string memory t,
        string memory p,
        TokenErc20 token
    ) public {
        require(bytes(t).length > 0, "voting title is required");
        require(bytes(p).length > 0, "voting proposal is required");
        voting.title = t;
        voting.proposal = p;
        voting.starttime = 0;
        voting.endtime = 0;
        voting.tokenErc20 = token;
    }

    function setVotingTime(uint256 starttime, uint256 endtime) public restrict {
        if (starttime == 0 && endtime > 0) {
            starttime = now;
            endtime += starttime;
        }
        require(endtime != 0, "endttime is not defined");
        require(starttime != 0, "startime is not defined");
        require(endtime > starttime, "endttime is not after starttime");
        require(starttime >= now, "start time must be in the future");
        require(
            voting.starttime == 0 && voting.endtime == 0,
            "time is already configured"
        );
        voting.starttime = starttime;
        voting.endtime = endtime;
    }

    function title() public view returns (string memory) {
        return voting.title;
    }

    function proposal() public view returns (string memory) {
        return voting.proposal;
    }

    function starttime() public view returns (uint256) {
        return voting.starttime;
    }

    function endtime() public view returns (uint256) {
        return voting.endtime;
    }

    function aye() public view isclosed returns (uint256) {
        return voting.aye;
    }

    function nay() public view isclosed returns (uint256) {
        return voting.nay;
    }

    function abstain() public view isclosed returns (uint256) {
        return voting.abstain;
    }

    function standDown() public view isclosed returns (uint256) {
        return voting.standDown;
    }

    function tokenErc20() public view returns (TokenErc20) {
        return voting.tokenErc20;
    }

    function voters(address i) public view returns (bool) {
        return voting.voters[i];
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
        return (accepted(), voting.endtime, voting.title, voting.proposal);
    }

    function closed() public view returns (bool) {
        return
            voting.starttime > 0 && voting.endtime > 0 && now >= voting.endtime;
    }

    function started() public view returns (bool) {
        return
            voting.starttime > 0 &&
            voting.endtime > 0 &&
            now >= voting.starttime;
    }

    function running() public view returns (bool) {
        return started() && !closed();
    }

    function accepted() public view isclosed returns (bool) {
        return voting.aye > voting.nay;
    }

    function rejected() public view isclosed returns (bool) {
        return voting.aye <= voting.nay;
    }

    function votes() public view isclosed returns (uint256, uint256) {
        return (voting.aye, voting.nay);
    }

    function canVote(address sender) public view returns (bool) {
        return !closed() && !voting.voters[sender];
    }

    function addressToBytes(address a) internal pure returns (bytes memory) {
        bytes memory b = new bytes(20);
        for (uint256 i = 0; i < 20; i++)
            b[i] = bytes1(uint8(uint256(a) / (2**(8 * (19 - i)))));
        return b;
    }

    function castVote(
        string memory text,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        internal
        isRunning
        returns (
            bytes memory message,
            address shareholder,
            uint256 shares
        )
    {
        message = abi.encodePacked(text, addressToBytes(address(this)));
        require(hash == keccak256(message), "wrong hash value sent");
        shareholder = ecrecover(hash, v, r, s);
        require(
            shareholder != address(0x0),
            "identification failed due to invalid signature"
        );
        require(!voting.voters[shareholder], "already voted");
        shares = voting.tokenErc20.balanceOf(shareholder);
        require(shares > 0, "not a validated shareholder");
        voting.voters[shareholder] = true;
    }

    function voteYes(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        returns (
            bytes memory message,
            address shareholder,
            uint256 shares
        )
    {
        (message, shareholder, shares) = castVote("YES on ", hash, v, r, s);
        voting.aye += shares;
    }

    function voteNo(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        returns (
            bytes memory message,
            address shareholder,
            uint256 shares
        )
    {
        (message, shareholder, shares) = castVote("NO on ", hash, v, r, s);
        voting.nay += shares;
    }

    function abstainVoting(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        returns (
            bytes memory message,
            address shareholder,
            uint256 shares
        )
    {
        (message, shareholder, shares) = castVote("ABSTAIN on ", hash, v, r, s);
        voting.abstain += shares;
    }

    function standDownVoting(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        returns (
            bytes memory message,
            address shareholder,
            uint256 shares
        )
    {
        (message, shareholder, shares) = castVote(
            "STAND_DOWN on ",
            hash,
            v,
            r,
            s
        );
        voting.standDown += shares;
    }
}
