pragma solidity ^0.4.24;
contract Named {
  bytes32 public name;
}


contract Owned {
     
    address public owner;
    constructor() { owner = msg.sender; }
    
    modifier onlyOwner{
        require(
            msg.sender == owner, 
            "Permission denied: Owner permission required"
        );
        _;
    }
}
contract Authorized {

    TaxAuthority public authority;
    constructor() { authority = TaxAuthority(msg.sender); }
    
    modifier onlyAuthority{
        require(
           TaxAuthority(msg.sender) == authority,
            "Permission denied: Authority permission required"
        );
        _;
    }
}
contract TaxAuthority is Named, Owned{

    mapping(bytes32 => Property) public propertyMap;

    TaxBill[] public taxBills;
    uint public taxBillCount;
    uint public transferTaxRate;
    uint public auditThreshold;

    event NewTaxBill (
	uint taxBillIndex
    );

    event PropertyTransfered(
	bytes32 propertyName,
	address newOwner
    );
    
    event NewProperty (
	bytes32 propertyName
    );

    enum BillPaidStatus{
	Underpaid,
	Overpaid,
	ExactlyPaid
    }

    event BillPaid (
	BillPaidStatus status
    );

    constructor(bytes32 displayName){
	name = displayName;
    }

    // function getIndexOfPropertyName(bytes32 propertyName) pure returns (bytes32){
    // 	return keccak256(bytes(propertyName));
    // }

    function getPropertyByName(bytes32 propertyName) view returns (Property) {
	return propertyMap[propertyName];
	// return propertyMap[getIndexOfPropertyName(propertyName)];
    }

    function nameIsTaken(bytes32 propertyName) view returns (bool){
	return address(propertyMap[propertyName]) != 0;	
	// return address(propertyMap[getIndexOfPropertyName(propertyName)]) != 0;
    }

    function createProperty(bytes32 propertyName){

	require(!nameIsTaken(propertyName),"Sorry, that name is taken");

	// bytes32 hash = getIndexOfPropertyName(propertyName);

	Property prop = new Property(propertyName);

	// propertyMap[hash] = prop;
	propertyMap[propertyName] = prop;	
	
	emit NewProperty(propertyName);// propertyName); // hash);
    }

    function transferProperty(
	bytes32 propertyName,
	address newOwner
    ) onlyOwner{
	getPropertyByName(propertyName).setOwner(newOwner);
	emit PropertyTransfered(propertyName, newOwner);
    }

    function setPropertyAssessedValue(
	Property property,
	uint newValue
    ){
	property.setAssessedValue(newValue);
    }

    function setTransferTaxRate(uint rate) onlyOwner{
	transferTaxRate = rate;
    }

    function setAuditThreshold(uint thresh) onlyOwner{
	auditThreshold = thresh;
    }

    function createTaxBill(uint rate){
	TaxBill bill = new TaxBill(rate);
	taxBills.push(bill);
	emit NewTaxBill(taxBillCount);
	taxBillCount += 1;	
    }

    function payBill(Property property) payable {

	// nothing to do
	if (property.isPaidCurrent()) { return ; }

	TaxBill bill = taxBills[property.billIndex()];

	uint amountDue = bill.amountDue(property);

	if (msg.value < amountDue){
	    // insufficient payment. return it
	    msg.sender.transfer(msg.value);
	    emit BillPaid(BillPaidStatus.Underpaid);
	} else if (msg.value == amountDue){
	    // exact amount paid
	    property.setBillIndex(property.billIndex() +1);
	    bill.addToReceipts(amountDue);
	    emit BillPaid(BillPaidStatus.ExactlyPaid);	    
	} else {
	    // overpaid. send back change
	    uint change = msg.value - amountDue;
	    msg.sender.transfer(change);
	    property.setBillIndex(property.billIndex() +1);
	    bill.addToReceipts(amountDue);
	    emit BillPaid(BillPaidStatus.Overpaid);	    
	}
	
    }

    function maximumSalePrice(uint value) view returns (uint) {
	return value + (auditThreshold * value / 1000);
    }

    function finalizeTransfer(address buyer, Property property) payable{

	// make sure amount does not trigger threshold
	if(msg.value > maximumSalePrice(property.assessedValue())){
	    // reject sale
	    // buyer.transfer(msg.value);
	    return;
	}

	// take a cut and transfer the rest to the seller
	uint cut = transferTaxRate * msg.value / 1000;
	property.owner().transfer(msg.value - cut);
	
	// transferTheProperty
	// transferProperty(property.name(), buyer);
	property.setOwner(buyer);
	emit PropertyTransfered(property.name(), buyer);	
    }

}

// contract Taxed is Authorized{
    
//     uint public assessedValue;
    
//     function setAssessedValue(uint newValue) onlyAuthority{
//         assessedValue = newValue;
//     }
// }

contract Traded {

    enum OfferStatus{
        Active,
        Revoked
    }

    struct Offer{
        uint expiration;
        uint amount;
        uint buyer;
    }
    
    uint public minimumBidAmount;
    Offer[] offers;
    
    function makeOffer(uint expiration) payable{
        if (msg.value < minimumBidAmount) return;
    }
    
}
contract Property is Named, Authorized, Owned {

    uint public billIndex;
    uint public minimumBid;
    uint public assessedValue;

    Offer[] public offers;
    uint public offerCount;

    event NewOffer(
	uint offerIndex
    );
    
    constructor(bytes32 propertyName){
        name = propertyName;
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

contract TaxBill is Authorized{
    
    uint public taxRate;
    uint public totalReceipts;
    uint public billIndex;
    uint public dueDate;
    
    constructor(uint rate){

	// user-settable
        taxRate = rate;
	
	// default starting values
	totalReceipts = 0;
    }
    
    // function cancel() onlyAuthority{
    //     status = TaxBillStatus.Revoked;
    // }
    
    function amountDue(Property property) view returns (uint) {
	if (property.billIndex() > billIndex){ return 0; }
        return property.assessedValue() * taxRate / (1000);
    }

    function addToReceipts(uint amount){
	totalReceipts += amount;
    }
}

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
