pragma solidity ^0.4.23;

import "./erc20/ERC20.sol";

contract MobilityPlatform {

    enum Status { OfferProposed, OfferAccepted, OfferDeclined, UsageStarted, UsageEnded, Paid }

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

    function getUsageRecord(uint offerId) public view returns
    (uint, address, address, uint, uint, uint, uint, uint, uint, Status, string) {
        UsageRecord memory rec = usageRecords[offerId];

        return (rec.offerId, rec.provider, rec.user, rec.offerValidUntil, rec.serviceUsageStartTime, rec.serviceUsageEndTime,
        rec.distanceTravelled, rec.pricePerKm, rec.totalPrice, rec.status, rec.hashv);
    }

    function proposeServiceUsage(uint offerId, uint offerValidUntil, uint pricePerKm, address user) public {
        address provider = msg.sender;
        usageRecords[offerId] = UsageRecord(offerId, provider, user, offerValidUntil, 0, 0, 0, pricePerKm, 0, Status.OfferProposed, "");
//        usageRecords[offerId].hashv = keccak256(usageRecords[offerId]));

        emit ServiceUsageProposed(offerId, provider, pricePerKm, offerValidUntil, usageRecords[offerId].hashv);
    }

    function acceptProposedOffer(uint offerId) public {
        Status expectedStatus = Status.OfferProposed;
        address checkedAddress = usageRecords[offerId].user;
        if (usageRecords[offerId].status != expectedStatus || checkedAddress != msg.sender) {
            emit ContractChangeRejected(offerId, checkedAddress, msg.sender, usageRecords[offerId].status, expectedStatus);

            // actually offer shall be rejected, but for test purposes we are accepting it, that's why in case
            // the contact status is correct the processing is continued
            if (usageRecords[offerId].status != expectedStatus) {
                return;
            }
        }

        if (usageRecords[offerId].user != msg.sender) {
            emit OfferAcceptedForYou(offerId, usageRecords[offerId].user, msg.sender, usageRecords[offerId].provider);
        }


        usageRecords[offerId].status = Status.OfferAccepted;

        emit ServiceUsageProposalAccepted(offerId);
    }

    function declineProposedOffer(uint offerId) public {
        Status expectedStatus = Status.OfferProposed;
        address checkedAddress = usageRecords[offerId].user;
        if (usageRecords[offerId].status != expectedStatus || checkedAddress != msg.sender) {
            emit ContractChangeRejected(offerId, checkedAddress, msg.sender, usageRecords[offerId].status, expectedStatus);
            return;
        }

        usageRecords[offerId].status = Status.OfferDeclined;

        emit ServiceUsageProposalDeclined(offerId);
    }

    function startServiceUsage(uint offerId, uint serviceUsageStartTime) public {
        Status expectedStatus = Status.OfferAccepted;
        address checkedAddress = usageRecords[offerId].provider;
        if (usageRecords[offerId].status != expectedStatus || checkedAddress != msg.sender) {
            emit ContractChangeRejected(offerId, checkedAddress, msg.sender, usageRecords[offerId].status, expectedStatus);
            return;
        }


        usageRecords[offerId].status = Status.UsageStarted;
        usageRecords[offerId].serviceUsageStartTime = serviceUsageStartTime;
  //      usageRecords[offerId].hashv = keccak256(usageRecords[offerId]);

        emit ServiceUsageStarted(offerId, serviceUsageStartTime, usageRecords[offerId].hashv);
    }

    function finishServiceUsage(uint offerId, uint serviceUsageEndTime, uint distanceTravelled) public {
        Status expectedStatus = Status.UsageStarted;
        address checkedAddress = usageRecords[offerId].provider;
        if (usageRecords[offerId].status != expectedStatus || checkedAddress != msg.sender) {
            emit ContractChangeRejected(offerId, checkedAddress, msg.sender, usageRecords[offerId].status, expectedStatus);
            return;
        }

        usageRecords[offerId].status = Status.UsageEnded;
        usageRecords[offerId].serviceUsageEndTime = serviceUsageEndTime;
        usageRecords[offerId].distanceTravelled = distanceTravelled;
//        usageRecords[offerId].hashv = keccak256(usageRecords[offerId]);

        uint totalPrice = usageRecords[offerId].distanceTravelled * usageRecords[offerId].pricePerKm;
        usageRecords[offerId].totalPrice = totalPrice;
        emit ServiceUsageEnded(offerId, serviceUsageEndTime, distanceTravelled, totalPrice, usageRecords[offerId].hashv);
    }

    function executePayment(ERC20 balanceBook, uint offerId) public {
        Status expectedStatus = Status.UsageEnded;
        address checkedAddress = usageRecords[offerId].provider;
        if (usageRecords[offerId].status != expectedStatus || checkedAddress != msg.sender) {
            emit ContractChangeRejected(offerId, checkedAddress, msg.sender, usageRecords[offerId].status, expectedStatus);
            return;
        }

        uint price = usageRecords[offerId].totalPrice;

        if (balanceBook.balanceOf(usageRecords[offerId].user) < price) {
            emit PaymentFailedDueToUnsufficientFunds(offerId);
            return;
        }

        balanceBook.transferFrom(usageRecords[offerId].user, usageRecords[offerId].provider, price);

        usageRecords[offerId].status = Status.Paid;
//        usageRecords[offerId].hashv = keccak256(usageRecords[offerId]);

        emit ServiceUsagePayedUp(offerId, usageRecords[offerId].hashv);

        delete usageRecords[offerId];
    }


 /*
    modifier verifyCall(uint offerId, address checkedAddr, Status expectedStatus) {
        address checkedAddress = usageRecords[offerId].provider;
        if (usageRecords[offerId].status != expectedStatus || checkedAddress != msg.sender) {
            emit ContractChangeRejected(offerId, checkedAddress, msg.sender, usageRecords[offerId].status, expectedStatus);
            return;
        }
        _;
    }
*/
    event ServiceUsageProposed(uint offerId, address provider, uint pricePerKm, uint validUntil, string hashv);
    event ServiceUsageProposalAccepted(uint offerId);
    event ServiceUsageProposalDeclined(uint offerId);
    event ServiceUsageStarted(uint offerId, uint serviceUsageStartTime, string hashv);
    event ServiceUsageEnded(uint offerId, uint serviceUsageEndTime, uint distanceTravelled, uint serviceCost, string hashv);
    event ServiceUsagePayedUp(uint offerId, string hashv);
    event PaymentFailedDueToUnsufficientFunds(uint offerId);

    // warning events
    event OfferAcceptedForYou(uint offerId, address user, address acceptingaddress, address provider);

    // error events
    event ContractChangeRejected(uint offerId, address checkedAddr, address callingAddr, Status cState, Status expCState);
}
