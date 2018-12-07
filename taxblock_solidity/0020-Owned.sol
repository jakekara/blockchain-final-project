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