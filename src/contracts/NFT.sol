//we need to create mocks to create our test environment.

pragma solidity ^0.7.3;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';  //need a mock nft

contract NFT is ERC721{                           //our contract inherits the ERC721 functionality
  constructor(                                    //the constructor requires us to initialize the ERC721 name and symbol so we pass these as arguments
    string memory name,
    string memory symbol
  ) public
  ERC721(name, symbol) {}                         //instantiate the ERC721 contract
  
  function mint(address to, uint tokenId) external {      //use the ERC721 mint() to send the token to the to addres and you can usew the amount or the tokenId as long as there is an integer in this spot.
    _mint(to, tokenId);
    } 
  }
