contract Offer is Authorized{

    Property property;
    address public buyer;
    

    enum OfferStatus{
	Active,
	Inactive
    }

    event StatusChanged(bytes32 statusMessage);
    
    OfferStatus public status;

    modifier onlyActive {
	require(status == OfferStatus.Active,
		"This contract is no longer active");
	_;
    }

    constructor(Property _property) payable{
	buyer = msg.sender;
	property = _property;
	status = OfferStatus.Active;
	authority = _property.authority();
    }

    function accept() onlyActive{
	require(msg.sender == property.owner(),
		"Only the owner of the property can accept the offer");
	require(property.isPaidCurrent(),
		"The property has unpaid tax bills and cannot be sold");

	property.authority().finalizeTransfer.value(address(this).balance)(buyer, property);
	emit StatusChanged(bytes32("Offer accepted"));
    }

    function reject() onlyActive{
	require(msg.sender == property.owner(),
		"Only the owner of the property can reject the offer");
	buyer.transfer(address(this).balance);
	status = OfferStatus.Inactive;
    }

    function rescind() onlyActive{
	require(msg.sender == buyer,
		"Only the buyer can rescind the offer"
	       );
	buyer.transfer(address(this).balance);
	status = OfferStatus.Inactive;
    }

    function terminate() onlyAuthority{
	status = OfferStatus.Inactive;
    }
    
}
