// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    constructor()ERC721("Ammag", "AMG"){
    }
    function mintNFT(address _to, uint tokenID) public payable {       
        require (!_exists(tokenID), "token id already exist.");
        // require (msg.value==1 ether,"please send 1 ether fee for minting.");
        
        _mint(_to, tokenID);
    }
    function burnNFT(uint tokenID) public payable{
        require (_exists(tokenID), "token id already exist.");
        // require (msg.value==1 ether,"please send 1 ether fee for minting.");

        _burn(tokenID);
    }
    receive() external payable {

    }
}