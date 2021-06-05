pragma solidity 0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol"

contract MbondX is ERC721("Mbond", "mbond"){
    
    
      struct OfferInfo{
           address buyer;
           uint Pay_amt;
           uint no_of_bond;
           uint time;
           }
           
      
           
      struct BondInfo{
           uint no_of_bond;
           uint maturity_date;
           uint couponRate;
           uint Principal;
           address lastOwner;
           address newOwner;
           
          }
     
             
      BondInfo [] public _bonds; 

      uint public last_offer_id  = 999;
      mapping (uint => OfferInfo) public offers; 
      mapping(uint  => BondInfo) public B_id;
      mapping(uint => bool) _is_id_active;
      
      
      struct sortInfo{
          uint id;
          uint price;
          address _maker;
          
      }
      
      sortInfo [] public sortList;
      
      mapping(uint => sortInfo) rank;
     
      address [] public coupon_receiving_address;
      
      event offer_made(address maker, uint price,  uint number);
      event taker(address maker, address taker, uint number);
      event cancelled(address _cancelled);
      
       
       modifier isActive(uint id){
           
           require(_is_id_active[id] == true, "id not active");
           _;
       }
       
       
       
       
       function offer(uint price, uint _no_of_bonds) public{
           
          
           OfferInfo memory _info ;
           _info.buyer = msg.sender;
           _info.Pay_amt = price;
           _info.time = block.timestamp;
           
           offers[last_offer_id] = _info;
           uint id = last_offer_id;
           _is_id_active[id] = true;
           
           sortInfo memory _sort;
           
           _sort.id = id;
           _sort.price= price;
           _sort._maker = msg.sender;
           
           // sort()
           rank[1] = _sort;
           
           emit offer_made(msg.sender, price, _no_of_bonds);
           
            

           last_offer_id++;
           
          
            }
            
            
            
    function cancel(uint Id) public returns(bool){
        
        _is_id_active[Id] = false;
         delete offers[Id];
          
          emit cancelled(msg.sender);
         
        return true;
    }
    
    
    function buy(uint no_of_bond, uint price) payable  public {
        
          require(price >= msg.value);
        
           sortInfo memory _sort = rank[1];
           
           address oldOwner = _sort._maker;
           
           if( _sort.price  == price ){
               
          (bool s, ) =   _sort._maker.call{value : price - 1000}("");
          
           require(s, " failed");
           
             uint id = _sort.id;
             
              delete offers[id];
            BondInfo memory b_info;
           b_info.no_of_bond = price;
           b_info.maturity_date = block.timestamp + 3600;
           b_info.couponRate = 5;
           b_info.Principal = 1000; /// 1000$
           b_info.lastOwner = address(0);
           b_info.newOwner = msg.sender;
           _bonds.push(b_info);
           B_id[_bonds.length + 1] = b_info;
           
           coupon_receiving_address.push(msg.sender);
           
            mint( msg.sender, id);
           
        /// sort()
        
         emit taker(oldOwner, msg.sender, no_of_bond );
        
     }
    
    function balance () external view returns(uint){
        
        return address(this).balance;
    }
    
    

}
