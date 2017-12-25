pragma solidity ^0.4.18;
import './Ownable.sol';
import './SafeMath.sol';

contract BirdyLog is Ownable {
    // Event declarations
    event newDonor (address indexed donor);
    event newDonation (address indexed donor, uint256 weiDonated);
    event birdyStack(address log, address donations, address feeder);

    event birdsUpdated(uint256 newBirds);
    event paidOut (address indexed breeder, uint256 amount);
    event breederChanged (address indexed breeder);
    event payoutChanged (uint256 payout);

    // Event triggers
    function NEW_DONOR (address donor) public {
        newDonor(donor);
    }

    function NEW_DONATION (address donor, uint256 weiDonated) public {
        newDonation(donor, weiDonated);
    }

    function BIRDY_STACK (address log, address donations, address feeder) public {
        birdyStack(log, donations, feeder);
    }

    function BIRDS_UPDATED (uint256 newBirds) public {
        birdsUpdated(newBirds);
    }

    function PAID_OUT (address breeder, uint256 amount) public {
        paidOut (breeder, amount);
    }

    function BREEDER_CHANGED (address breeder) public {
        breederChanged (breeder);
    }

    function PAYOUT_CHANGED (uint256 payout) public {
        payoutChanged(payout);
    }
}

contract BirdyDonations {

    uint256 weiDonated;
    uint256 donorsCounter;

    BirdyLog log;
    Birdy feeder;

    mapping (address => uint256) donated;
    mapping (uint256 => address) donorsList;

    function BirdyDonations(Birdy _feeder, BirdyLog _log) public {
        feeder = _feeder;
        log = _log;
    }

    function () payable public {
        require(msg.value > 0);
        if (donated[tx.origin] == 0) {
            donorsList[donorsCounter] = tx.origin;
            donorsCounter += 1; // Will potentially overflow, but that's ok
            log.NEW_DONOR(tx.origin);
        }
        weiDonated += msg.value; // Will potentially overflow, but that's ok
        donated[tx.origin] += msg.value; // Will potentially overflow, but that's ok
        forwardFunds();
        log.NEW_DONATION(tx.origin, msg.value);
    }

    function forwardFunds() internal {
        feeder.transfer(msg.value);
    }
}

contract Birdy is Ownable{
    using SafeMath for uint256;

    BirdyLog log;
    BirdyDonations donations;

    mapping (address => uint256) streak;

    address breeder;
    uint256 timeChanged; //choose smaller uint type
    uint256 birdsSince;
    uint256 birdsTotal;

    uint256 payPerBird = 100 wei;

    event newbreeder();

    function Birdy() {
        log = new BirdyLog();
        donations = new BirdyDonations(this, log);
        log.BIRDY_STACK(log, donations, this);
    }

    function () public payable{
        if (msg.sender == address(donations)) {
            // do nothing
        }
        
        else {
            uint256 timeDiff = now - timeChanged;

            require (timeDiff >= 3600);
            require (breeder != msg.sender);

            streak[breeder] += timeDiff;

            payOutNow();

            breeder = msg.sender;
            timeChanged = now;

            log.BREEDER_CHANGED(msg.sender);
        }
    }

    function iterateBirds(uint256 birds) public onlyOwner {
        birdsSince += birds;
        birdsTotal += birds;
        log.BIRDS_UPDATED(birds);
    }

    function payOut() public onlyOwner {
        uint256 payout = birdsSince.mul(payPerBird);
        birdsSince = 0;

        breeder.transfer(payout);
        // TODO: "Error" handling

        log.PAID_OUT(breeder, payout);
    }

    function payOutNow() internal {
        uint256 payout = birdsSince.mul(payPerBird);
        birdsSince = 0;

        breeder.transfer(payout);
        // TODO: "Error" handling

        log.PAID_OUT(breeder, payout);
    }

    // Settings
    function changePayout(uint256 _new) public onlyOwner {
        payPerBird = _new;
        log.PAYOUT_CHANGED(_new);
    }
}

