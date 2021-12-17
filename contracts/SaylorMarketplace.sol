//SPDX-License-Identifier: QLIPIT.io
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract SaylorMarketplace is ERC721URIStorage{
	//maps tokenIds to item indexes
	using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
	mapping(uint256 => uint256) private itemIndex;
	mapping(uint256 => uint256) private salePrice;
	
	event Minted(address minter, string tokenURI, uint256 tokenId);
    event SetSale(address seller, uint256 tokenId);
    event BuyToken(address seller, address buyer, uint256 tokenId);

	constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {

    }

	function setSale(uint256 tokenId, uint256 price) public {
		address owner = ownerOf(tokenId);
        require(owner != address(0), "setSale: nonexistent token");
        require(owner == msg.sender, "setSale: msg.sender is not the owner of the token");
		salePrice[tokenId] = price;
		
		emit SetSale(msg.sender, tokenId);
	}

	function buyTokenOnSale(uint256 tokenId) public payable {
		uint256 price = salePrice[tokenId];
        require(price != 0, "buyToken: price equals 0");
        require(msg.value == price, "buyToken: price doesn't equal salePrice[tokenId]");
		address payable owner = payable((ownerOf(tokenId)));
		approve(address(this), tokenId);
		salePrice[tokenId] = 0;
		
		transferFrom(owner, msg.sender, tokenId);
        owner.transfer(msg.value);
        
        emit BuyToken(owner, msg.sender, tokenId);
	}

	function mintWithIndex(address to, string memory tokenURI) public  {
        
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _mint(to, tokenId);
        
        //Here, we will set the metadata hash link of the token metadata from Pinata
        _setTokenURI(tokenId, tokenURI);
        emit Minted(msg.sender, tokenURI, tokenId);
	}
	

	function getSalePrice(uint256 tokenId) public view returns (uint256) {
		return salePrice[tokenId];
	}
}
