contract TaxAuthority is Named, Owned{

    mapping(bytes32 => Property) public propertyMap;

    TaxBill[] public taxBills;
    uint public taxBillCount;
    uint public transferTaxRate;
    uint public auditThreshold;
    
    enum BillPaidStatus{
	Underpaid,
	Overpaid,
	ExactlyPaid
    }

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
