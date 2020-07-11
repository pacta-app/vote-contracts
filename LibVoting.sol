pragma solidity >=0.0;

import "./libsign.sol";
import "./TokenErc20Ifc.sol";

library LibVoting {
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

    enum Vote {
        Yes, /*0*/
        No, /*1*/
        Abstain, /*2*/
        StandDown /*3*/
    }

    function construct(
        Data storage data,
        string memory title,
        string memory proposal,
        TokenErc20 token
    ) public {
        require(bytes(title).length > 0, "voting title is required");
        require(bytes(proposal).length > 0, "voting proposal is required");
        data.title = title;
        data.proposal = proposal;
        data.starttime = 0;
        data.endtime = 0;
        data.tokenErc20 = token;
    }

    function setVotingTime(
        Data storage data,
        uint256 starttime,
        uint256 endtime
    ) public {
        if (starttime == 0 && endtime > 0) {
            starttime = now;
            endtime += starttime;
        }
        require(endtime != 0, "endttime is not defined");
        require(starttime != 0, "startime is not defined");
        require(endtime > starttime, "endttime is not after starttime");
        require(starttime >= now, "start time must be in the future");
        require(
            data.starttime == 0 && data.endtime == 0,
            "time is already configured"
        );
        data.starttime = starttime;
        data.endtime = endtime;
    }

    function castVote(
        Data storage data,
        Vote vote,
        address a,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public returns (uint256 shares) {
        address shareholder = libsign.verify(abi.encode(vote, a), v, r, s);
        require(!data.voters[shareholder], "already voted");
        shares = data.tokenErc20.balanceOf(shareholder);
        require(shares > 0, "not a validated shareholder");
        data.voters[shareholder] = true;
        if (vote == Vote.Yes) {
            data.aye += shares;
        } else if (vote == Vote.No) {
            data.nay += shares;
        } else if (vote == Vote.Abstain) {
            data.abstain += shares;
        } else if (vote == Vote.StandDown) {
            data.standDown += shares;
        }
    }

    /* function voteYes(
        Data storage data,
        address a,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        data.aye += castVote(data, a, v, r, s);
    }

    function voteNo(
        Data storage data,
        address a,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        data.nay += castVote(data, a, v, r, s);
    }

    function voteAbstain(
        Data storage data,
        address a,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        data.abstain += castVote(data, a, v, r, s);
    }

    function voteStandDown(
        Data storage data,
        address a,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        data.standDown += castVote(data, a, v, r, s);
    } */
}
