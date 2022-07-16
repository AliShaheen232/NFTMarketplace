// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./CLG.sol";

contract NFTMarket is ReentrancyGuard {
    struct Listing {
        address seller;
        uint price;
        uint tokenPrice;
    }
    event ItemListed(address indexed seller, address indexed nftAddress,uint tokenID,uint price);
    event ItemCanceled(address indexed seller, address indexed nftAddress,uint tokenID);
    event ItemBought(address indexed buyer, address indexed nftAddress,uint tokenID);
    
    mapping (address => mapping (uint => Listing)) private p_listings;
    mapping (address => uint) private p_proceeds;
    mapping (address => uint) private p_tokenProceeds;

    address private _token;

    constructor(address token) {
        console.log("im in");
        _token = token;
    }

    ////Modifiers

    function listItem(address nftAddress, uint tokenID, uint price, uint tokenPrice) public {
        IERC721 nft = IERC721(nftAddress);
        require (nft.getApproved(tokenID) == address(this), "marketplace not approved for item.");
        require (price == 0 && tokenPrice > 0 || price > 0 && tokenPrice == 0, "set a valid price.");
        // require (price > 0 && tokenPrice == 0, "set valid price.");
    
        p_listings[nftAddress][tokenID]=Listing(msg.sender, price, tokenPrice);
        emit ItemListed(msg.sender, nftAddress, tokenID,price);
    }

    function cancelListing(address nftAddress,uint tokenID) public {
        require (p_listings[nftAddress][tokenID].seller != address(0), "no such item is listed.");
        delete(p_listings[nftAddress][tokenID]);
        emit ItemCanceled(msg.sender, nftAddress, tokenID);
    }

    function buyItem(address nftAddress, uint tokenID) public payable{
        Listing memory listing = p_listings[nftAddress][tokenID] ;
        require (msg.value == listing.price, "enter exact price.");

        IERC721 nft = IERC721(nftAddress);
        nft.transferFrom(listing.seller, msg.sender,tokenID);
        delete(p_listings[nftAddress][tokenID]);

        p_proceeds[listing.seller] += msg.value;                
        emit ItemBought(msg.sender,nftAddress, tokenID);
    }

    receive() external payable {
    }

    function updateItem(address nftAddress, uint tokenID, uint newPrice, uint newTokenPrice) public {
        require(p_listings[nftAddress][tokenID].seller == msg.sender, "only seller can update the item.");
        require (newPrice == 0 && newTokenPrice > 0 || newPrice > 0 && newTokenPrice == 0, "set a valid price.");

        p_listings[nftAddress][tokenID].price = newPrice;
        p_listings[nftAddress][tokenID].price = newTokenPrice;
    }

    function getListing(address nftAddress, uint tokenID) external view returns (address seller , uint price, uint tokenPrice){
        return (p_listings[nftAddress][tokenID].seller, p_listings[nftAddress][tokenID].price, 
                p_listings[nftAddress][tokenID].tokenPrice);
    }

    function withdrawProceed()public {
        uint amount = p_proceeds[msg.sender];
        require (amount > 0, "no amount to withdraw.");
        p_proceeds[msg.sender] = 0;
        (bool success,) = payable(msg.sender).call{value: amount}("");
        require (success,"transaction failed.");
    }

    function getProceeds(address seller) public view returns(uint){
    
        return p_proceeds[seller];
    }

    ////////////////////////Token Section/////////////////////////////

    function transferTokenToMarket(uint _amount) public{
        IERC20 erc20Token=IERC20(_token);
        require(erc20Token.allowance(msg.sender,address(this))>0, "no amount approve for this contract.");
        erc20Token.transferFrom(msg.sender,address(this),_amount);
    }

    function tokenBuyItem(address nftAddress, uint tokenID, uint _amount) public payable{
        Listing memory listing = p_listings[nftAddress][tokenID] ;
        require (_amount == listing.tokenPrice, "enter exact token price.");

        transferTokenToMarket(_amount);
        IERC721 nft = IERC721(nftAddress);
        nft.transferFrom(listing.seller, msg.sender,tokenID);
        delete(p_listings[nftAddress][tokenID]);
     
        p_tokenProceeds[listing.seller] += _amount; 
        emit ItemBought(msg.sender, nftAddress, tokenID);
    }
    
    function tokenGetProceeds() public view returns(uint){
        return p_tokenProceeds[msg.sender];
    }

    function tokenWithdrawProceed()public {
        uint amount = p_tokenProceeds[msg.sender];
        require (amount > 0, "no amount to withdraw.");
        p_tokenProceeds[msg.sender] = 0;

        IERC20 erc20Token=IERC20(_token);
        erc20Token.transfer(msg.sender,amount);
    }
}