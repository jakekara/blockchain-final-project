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