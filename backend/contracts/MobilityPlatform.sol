pragma solidity ^0.4.23;

contract MobilityPlatform {

    enum Status { OfferProposed, OfferAccepted, OfferDeclined, UsageStarted, UsageEnded, Paid }

    constructor() public {
        userAccountBalance[0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe] = 2000; //Demo user account
    }
    struct UsageRecord {
        uint offerId;
        address provider;
        address user;
        uint offerValidUntil;
        uint serviceUsageStartTime;
        uint serviceUsageEndTime;
        uint distanceTravelled;
        uint pricePerKm;
        uint totalPrice;
        Status status;
        string hashv;
    }
            
    mapping(uint => UsageRecord) usageRecords;

    mapping(address => uint) userAccountBalance;
   
    mapping(address => uint) providerAccountBalance;

    function getUsageRecord(uint offerId) public view returns 
    (uint, address, address, uint, uint, uint, uint, uint, uint, Status, string) {
        UsageRecord memory rec = usageRecords[offerId];

        return (rec.offerId, rec.provider, rec.user, rec.offerValidUntil, rec.serviceUsageStartTime, rec.serviceUsageEndTime,
        rec.distanceTravelled, rec.pricePerKm, rec.totalPrice, rec.status, rec.hashv);
    }

    function proposeServiceUsage(uint offerId, uint offerValidUntil, uint pricePerKm, address user) public {
        address provider = msg.sender;
        usageRecords[offerId] = UsageRecord(offerId, provider, user, offerValidUntil, 0, 0, pricePerKm, 0, 0, Status.OfferProposed, "");
//        usageRecords[offerId].hashv = keccak256(usageRecords[offerId]));

        emit ServiceUsageProposed(offerId, provider, pricePerKm, offerValidUntil, usageRecords[offerId].hashv);
    }
    
    function acceptProposedOffer(uint offerId) public {
        if (usageRecords[offerId].status != Status.OfferProposed) revert();
        if (usageRecords[offerId].user == msg.sender) revert();
        
        usageRecords[offerId].status = Status.OfferAccepted;
    
        emit ServiceUsageProposalAccepted(offerId);
    }

    function declineProposedOffer(uint offerId) public {
        if (usageRecords[offerId].status != Status.OfferProposed) revert();
        if (usageRecords[offerId].user == msg.sender) revert();
        
        usageRecords[offerId].status = Status.OfferDeclined;
    
        emit ServiceUsageProposalDeclined(offerId);
    }

    function startServiceUsage(uint offerId, uint serviceUsageStartTime) public {
        if (usageRecords[offerId].status != Status.OfferAccepted) revert();
        if (usageRecords[offerId].provider == msg.sender) revert();
        
        usageRecords[offerId].status = Status.UsageStarted;
        usageRecords[offerId].serviceUsageStartTime = serviceUsageStartTime;
  //      usageRecords[offerId].hashv = keccak256(usageRecords[offerId]);

        emit ServiceUsageStarted(offerId, serviceUsageStartTime, usageRecords[offerId].hashv);
    }

    function finishServiceUsage(uint offerId, uint serviceUsageEndTime, uint distanceTravelled) public {
        if (usageRecords[offerId].status != Status.UsageStarted) revert();
        if (usageRecords[offerId].provider == msg.sender) revert();
   
        usageRecords[offerId].status = Status.UsageEnded;
        usageRecords[offerId].serviceUsageEndTime = serviceUsageEndTime;
        usageRecords[offerId].distanceTravelled = distanceTravelled;
//        usageRecords[offerId].hashv = keccak256(usageRecords[offerId]);
         
        uint totalPrice = usageRecords[offerId].distanceTravelled * usageRecords[offerId].pricePerKm;
        usageRecords[offerId].totalPrice = totalPrice;
        emit ServiceUsageEnded(offerId, serviceUsageEndTime, distanceTravelled, totalPrice, usageRecords[offerId].hashv);

        executePayment(offerId);
    }

    function executePayment(uint offerId) public {
        if (usageRecords[offerId].status != Status.UsageEnded) revert();
        if (usageRecords[offerId].provider == msg.sender || usageRecords[offerId].user == msg.sender) revert();
        
        uint price = usageRecords[offerId].totalPrice;
        if (userAccountBalance[usageRecords[offerId].user] < price) {
            emit PaymentFailedDueToUnsufficientFunds(offerId);
            return;
        }
        if (providerAccountBalance[usageRecords[offerId].provider] < 
            providerAccountBalance[usageRecords[offerId].provider] + price) {
            
            emit PaymentFailedDueToBalanceOverflow(offerId);
            return;
        }

        userAccountBalance[usageRecords[offerId].user] -= price;
        providerAccountBalance[usageRecords[offerId].provider] += price;
        usageRecords[offerId].status = Status.Paid;
//        usageRecords[offerId].hashv = keccak256(usageRecords[offerId]);

        emit ServiceUsagePayedUp(offerId, usageRecords[offerId].hashv);

        delete usageRecords[offerId];
    }

    event ServiceUsageProposed(uint offerId, address provider, uint pricePerKm, uint validUntil, string hashv);
    event ServiceUsageProposalAccepted(uint offerId);
    event ServiceUsageProposalDeclined(uint offerId);
    event ServiceUsageStarted(uint offerId, uint serviceUsageStartTime, string hashv);
    event ServiceUsageEnded(uint offerId, uint serviceUsageEndTime, uint distanceTravelled, uint serviceCost, string hashv);
    event ServiceUsagePayedUp(uint offerId, string hashv);
    event PaymentFailedDueToUnsufficientFunds(uint offerId);
    event PaymentFailedDueToBalanceOverflow(uint offerId);
}

