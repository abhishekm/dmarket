pragma solidity ^0.5.6; 
//pragma solidity >=0.4.25 <0.7.0;
pragma experimental ABIEncoderV2;
// import in VS code

contract DMarket { 
    Order[] public orders;
   //address payable public buyerAddress;
    
    
    // deploy different order contracts
    function createOrder() public payable { //buyer calls this
    Order order = new Order(msg.sender);
    orders.push(order);   
  }
  
  
// get this contract address
  function getAddress() public view returns(address) {
      return address(this);
  }
  
  // get all orders deployed
    function getOrders() public view returns(Order[] memory) {
      return orders;
   }

   
}

contract Order { 
    
    address payable public buyer;
    struct Product { 
        address payable sellerId;
        uint prodId;
        string prodName; 
        uint prodPrice;
        string prodDesc; 
        string prodSpec; 
        string rating;
        ProductStatus status;
    }
    Product public product;
    Product public boughtProduct;
 
    enum ProductStatus { Unconfirmed, Shipped, Delivered }
    ProductStatus public prodStat;
    
    function addProduct(uint prodId, string memory prodName, uint prodPrice,
    string memory prodDes, string memory prodSpec, string memory rating) public { 
        product = Product(msg.sender, prodId, prodName, prodPrice, prodDes, prodSpec, rating, ProductStatus.Unconfirmed);
    }
    
    constructor(address payable _buyer) public payable{
        buyer = _buyer;
    }
    
 
    event productsBought(address buyer, uint amount, string productName);
   
    // products in cart
    function getProduct() public view returns(Product memory) {
        return product;
    }
    
    // products in cart
    function getProductBought() public view returns(Product memory) {
        return boughtProduct;
    }

     function buyProduct() public payable{
         //buyer = msg.sender;
        require(msg.value == product.prodPrice);
        require(product.status == ProductStatus.Unconfirmed);
         boughtProduct = product;
        
        emit productsBought(msg.sender,msg.value,boughtProduct.prodName);
    }

     function sellerShipped() public {
          require(msg.sender == boughtProduct.sellerId);
        // DMarket.Product memory shippedProduct = prod;
        boughtProduct.status = ProductStatus.Shipped;
     }
    
    // buyer confirms delivery of the shipment 
    function productDelivered() public {
         //require(buyer == msg.sender);
         boughtProduct.status = ProductStatus.Delivered;
         paymentToSeller();
    }
    
     //seller receives the payment
     function paymentToSeller() payable public { 
       boughtProduct.sellerId.transfer(address(this).balance);
    }

  
   // get contract balance
   function getBalance () public view returns (uint) {
        return address(this).balance;
    }
  
  function getSellerBalance(address addr) public view returns (uint) {
        return address(addr).balance;
    }

   //fallback function
  function() payable external {
        
    }
}