contract Property is Named, Authorized, Owned {

    uint public assessedValue;
    uint public billIndex;
    uint public minimumBid; // I have not implemented this restriction yet

    Offer[] public offers;
    uint public offerCount;

    event NewOffer(
	uint offerIndex
    );
    
    constructor(bytes32 propertyName){
        name = propertyName;
        owner = msg.sender;
    }

    function setOwner(address newOwner) onlyAuthority{
    	owner = newOwner;
    }

    function setBillIndex(uint newIndex) onlyAuthority{
	billIndex = newIndex;
    }

    function isPaidCurrent() view returns (bool) {
	return billIndex >= authority.taxBillCount();
    }

    function setMinimumBid(uint amount) onlyOwner{
	minimumBid = amount;
    }

    function setAssessedValue(uint newValue) onlyAuthority{
        assessedValue = newValue;
    }

    function makeOffer(Offer offer) {
    	offers.push(offer);
	emit NewOffer(offerCount);
	offerCount += 1;
    }
    
}
