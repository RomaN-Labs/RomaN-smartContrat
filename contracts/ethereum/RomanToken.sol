// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "./RomanUser.sol";

contract RomanToken is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;
    
    // mapping users minted a token 
    mapping (address => bool) private _minted;

    // counter
    Counters.Counter private _tokenIdCounter;

    // init RomanUser contract
    // @dev TODO add the correct contract adderess after deploy
    address _rAdd = 0xDA0bab807633f07f013f94DD0E6A4F96F8742B53;
    RomanUser _r = RomanUser(_rAdd);


    // constructor --> set counter to 1 ==> first minted token is 1
    constructor() ERC721("RomanToken", "RMN") {
        _tokenIdCounter.increment();
    }

    // check if the sender minted a token
    modifier onlyOnce(address _sender) {
        require(_minted[_sender] == false, "Only one token is allowed");
        _minted[_sender] = true;
        _;
    }

    // check if the sender is the owner of the token
    modifier onlyTokenOwner(address _sender, uint256 _tokenId) {
        require(ownerOf(_tokenId) == _sender, "Only the owner can call this function");
        _;
    }

    // lock prohibited function
    modifier impossible() {
        require(0 > 1, "this function in not allowed");
        _;
    }

   // prohibted function  --> override token transfer functions
    function safeTransferFrom(address add, address to, uint256 tokenId, bytes memory data) public override impossible() {}
    function transferFrom(address add, address to, uint256 tokenId) public override impossible() {}

    // check if the address mint a token
    function didMint(address add) external view returns (bool) {
        return _minted[add];
    }

    // mint a token
    function safeMint(address to) public onlyOnce(to) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _minted[to] = true;
        _safeMint(to, tokenId);

        _r.CreateUser(address(to), tokenId, 100);
    }



    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    // get token uri by tokenId
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // set token uri by tokenId
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyTokenOwner(msg.sender, tokenId) {
        _setTokenURI(tokenId,_tokenURI);
    }

    // burn token by tokenId
    // @dev ATTENTION tokenId and address are set to 0
    function burn(uint256 tokenId) public onlyTokenOwner(msg.sender, tokenId) {
        _burn(tokenId);
        _minted[ownerOf(tokenId)] = false;
        _r.removeUser(tokenId);
    }

}