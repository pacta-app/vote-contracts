pragma solidity >=0.0;

contract hasapi {
    address internal api;

    modifier apionly() {
        require(msg.sender == api, "call only allowed from the api");
        _;
    }

    constructor(address _api) internal {
        api = _api;
    }
}
