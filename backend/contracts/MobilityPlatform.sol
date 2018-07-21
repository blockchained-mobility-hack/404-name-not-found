pragma solidity ^0.4.23;

contract MobilityPlatform {

    enum Status {Booked, Proposed, Accepted, Paid, OfferDeclined}

    constructor() public {
        userAccountBalance[0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe] = 2000; //Demo user account
    }
    struct UsageRecord {
        uint offerId;
        address provider;
        address user;
        uint timeStarted;
        uint timeFinished;
        uint proposedPrice;
        uint paidPrice;
        Status status;
    }
            
    mapping(uint => UsageRecord) usageRecords;

    mapping(address => uint) userAccountBalance;
   
    mapping(address => uint) providerAccountBalance;
            
    function proposeServiceUsage(uint offerId, uint timeStarted, uint proposedPrice, address user) public {
        address provider = msg.sender;
        usageRecords[offerId] = UsageRecord(offerId, provider, user, timeStarted, 0, proposedPrice, 0, Status.Proposed);
        emit ServiceUsageProposalSaved(offerId);
    }
        
    //function acceptService(uint offerId) public {
    //}
    //function getUserBalance() public view  returns (uint balance){
    //balance = userAccountBalance[msg.sender];
    //}
    //function finishServiceUsage(uint serviceId, uint timeFinished) public{
    //}
    //function executePayment() public{
    //
    //}

    event ServiceUsageProposalSaved(uint offerId);
}

