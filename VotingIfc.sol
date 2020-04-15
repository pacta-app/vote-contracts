pragma solidity >=0.0;

import "./TokenErc20Ifc.sol";

interface VotingIfc {
    function tokenErc20() external view returns(TokenErc20);
}
