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