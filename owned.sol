pragma solidity >=0.0;

contract owned {
    address payable internal owner;
    event feePaid(address to, uint amount);
    // creator is owner
    constructor() public {
        owner = msg.sender;
    }
    // only owner is allowed to call restricted function
    modifier restrict {
        require(msg.sender==owner, "access denied, you are not the contract owner");
        _;
    }
    // requires a fee for the owner
    modifier fee(uint amount) {
        require(msg.value>=amount, "not enough payment for the fee");
        _;
        owner.transfer(amount);
        emit feePaid(owner, amount);
    }

    function getOwner() view public returns (address payable) {
        return owner;
    }

    // allow update of the owner
    function changeOwner(address payable newOwner) public restrict {
        owner = newOwner;
    }

    // move whole balance to the owner
    function withdraw() public restrict {
        owner.transfer(address(this).balance);
    }

    // get anonymous money in payable fallback
    event ownedPaymentReceived(owned receiver, uint256 amount);
    event ownedFallback(owned receiver);
    /*receive*/function() /*virtual*/ external payable {
        if (msg.value>0) {
            emit ownedPaymentReceived(this, msg.value);
        } else {
            emit ownedFallback(this);
        }
    }

}
