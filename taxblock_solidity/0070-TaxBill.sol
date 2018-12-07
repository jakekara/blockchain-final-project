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
