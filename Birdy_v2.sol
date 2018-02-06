pragma solidity ^0.4.18;
import './Ownable.sol';
import './SafeMath.sol';

contract Birdy is Ownable{
    using SafeMath for uint256;

    // Birds related vars
    address public feeder;
    address public breeder;
    uint256 public timeChanged; //TODO: choose smaller uint type
    uint256 public birdsSince;
    uint256 public birdsTotal;
    uint256 public donorsCounter;
    uint256 public weiDonated;
    uint256 public payPerBird;

    mapping (bytes32 => address) uids;
    mapping (address => uint256) streak;

    // Donations related mappings
    mapping (address => uint256) donated;
    mapping (uint256 => address) donorsList;

    // Event declarations
    event newDonor (address indexed donor);
    event newDonation (address indexed donor, uint256 weiDonated);

    event birdsUpdated(uint256 newBirds);
    event paidOut (address indexed breeder, uint256 amount);
    event breederChanged (address indexed breeder);
    event payoutChanged (uint256 payout);
    event uidRegistered (bytes32 indexed uid, address indexed breeder);
    event feederChanged (address feeder);

    modifier onlyFeeder() {
        require(msg.sender == feeder);
        _;
    }

    //    function Birdy(address _feeder, uint256 _payPerBird) {
    //        feeder = _feeder;
    //        payPerBird = _payPerBird;
    //    }

    function Birdy() {
        feeder = msg.sender;
        payPerBird = 100 wei;
    }

    // Donation
    function () payable public {
        require(msg.value > 0);
        if (donated[tx.origin] == 0) {
            donorsList[donorsCounter] = tx.origin;
            donorsCounter += 1; // Could potentially overflow, but that's ok
            newDonor(tx.origin);
        }
        weiDonated += msg.value; // Could potentially overflow, but that's ok. I hope it will!
        donated[tx.origin] += msg.value; // Could potentially overflow, but that's ok. I hope it will!
        newDonation(tx.origin, msg.value);
    }

    function changeBreeder(bytes32 _uid) public onlyFeeder {
        uint256 timeDiff = now - timeChanged;
        address newBreeder = uids[_uid];

        require (timeDiff >= 3600);
        require (breeder != newBreeder);
        require (newBreeder != 0);

        payOut();

        streak[breeder] += timeDiff;
        breeder = newBreeder;
        timeChanged = now;

        breederChanged(msg.sender);
    }

    function iterateBirds(uint256 birds) public onlyOwner {
        birdsSince += birds;
        birdsTotal += birds;
        birdsUpdated(birds);
    }

    function payOut() public onlyFeeder {
        uint256 payout = birdsSince.mul(payPerBird);
        birdsSince = 0;

        breeder.transfer(payout);
        // TODO: "Error" handling

        paidOut(breeder, payout);
    }

    // Settings
    function changePayout(uint256 _new) public onlyOwner {
        payPerBird = _new;
        payoutChanged(_new);
    }

    function registerUID(bytes32 _uid, address _address) public onlyFeeder {
        uids[_uid] = _address;
        uidRegistered(_uid, _address);
    }

    function changeFeeder(address _new) public onlyOwner {
        feeder = _new;
        feederChanged(_new);
    }
}

