pragma solidity ^0.4.18;
import './Ownable.sol';

contract BirdyLog is Ownable {
    // Event declarations
    event newDonor (address indexed donor);
    event newDonation (address indexed donor, uint256 weiDonated);
    event birdyStack(address log, address donations, address feeder);

    event birdsUpdated(uint256 newBirds);
    event paidOut (address indexed breeder, uint256 amount);
    event breederChanged (address indexed breeder);

    // Event triggers
    function newDonor(address donor) {
        newDonor(donor);
    }

    function newDonation(address donor, uint256 weiDonated) {
        newDonation(donor, weiDonated);
    }

    function birdyStack(address log, address donations, address feeder) {
        birdyStack(log, donations, feeder);
    }

    function birdsUpdated(uint256 newBirds) {
        birdsUpdated(newBirds);
    }

    function paidOut (address breeder, uint256 amount) {
        paidOut (breeder, amount);
    }

    function breederChanged (address breeder) {
        breederChanged (breeder);
    }

}

contract BirdyDonations {

    uint256 weiDontated;
    uint256 donorsCounter;

    BirdyLog log;
    Birdy feeder;

    mapping (address => uint256) donated;
    mapping (uint32 => address) donorsList;

    function BirdyDonations(Birdy _feeder, BirdyLog _log) public {
        feeder = _feeder;
        log = _log;
    }

    function () payable {
        require(msg.value > 0);
        if (donated[msg.origin] = 0) {
            donorsList[donorsCounter] = msg.origin;
            donorsCounter += 1; // Will potentially overflow, but that's ok
            log.newDonor(msg.origin);
        }
        weiDonated += msg.value; // Will potentially overflow, but that's ok
        donated[msg.origin] += msg.value; // Will potentially overflow, but that's ok
        forwardFunds();
        log.newDonation(msg.origin, msg.value);
    }

    function forwardFunds() payable internal {
        feeder.transfer(msg.value);
    }
}

contract Birdy is Ownable{
    using SafeMath for uin256;

    BirdyLog log;
    BirdyDontations donations;

    mapping (address => uint256) streak;

    address breeder;
    uint256 timeChanged; //choose smaller uint type
    uint256 birdsSince;
    uint256 birdsTotal;

    uint256 payPerBird = 100 wei;

    event newbreeder();

    function Birdy() {
        log = new BirdyLog();
        donations = new BirdyDonations(log);
        log.birdyStack(log, donations, this);
    }

    function () possible {
        uint256 memory timeDiff = now - timeChanged;

        require (timeDiff >= 3600);
        require (breeder != msg.sender);

        streak[breeder] += timeDiff;

        payOutNow();

        breeder = msg.sender;
        timeChanged = now;

        log.breederChanged(msg.sender);
    }

    function iterateBirds(uint256 birds) onlyOwner {
        birdsSince += birds;
        birdsTotal += birds;
        log.birdsUpdated(birds);
    }

    function payOut() public onlyOwner {
        uint256 payout = birdsSince.mul(payPerBird);
        birdsSince = 0;

        breeder.transfer(payout);
        // TODO: "Error" handling

        log.paidOut(breeder, payout);
    }

    function payOutNow() internal {
        uint256 payout = birdsSince.mul(payPerBird);
        birdsSince = 0;

        breeder.transfer(payout);
        // TODO: "Error" handling

        log.paidOut(breeder, payout);
    }

    // Settings
    function changePayout(uint256 _new) public onlyOwner {
        payPerBird = _new;
        log.payOutChanged(_new);
    }
}

