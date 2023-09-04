// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Web3Builders is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    uint256 maxSupply = 2000;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;

    mapping(address => bool) public allowList;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Web3Builders", "WE3") {}

    function _baseURI() internal pure override returns (string memory) {
        //return "ipfs://QmY5rPqGTN1rZxMQg2ApiSZc7JiBNs1ryDzXPZpQhC1ibm/";
        return "ipfs://QmbtYbmMb3yUee4RYVjoAN4hLCrWUjNQDGPGQvbqhK39RE/";
       
    }

    function pause() public onlyOwner {
        _pause();
    }
    function unpause() public onlyOwner {
        _unpause();
    }

    // modify the mint windows
    function editMintWindows(bool _publicMintOpen, bool _allowListMintOpen) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    // require only the allowList people to mint
    // Add publicMint and allowListMintOpen Variables
    function allowListMint() public payable {
        require(allowListMintOpen, "AllowList Mint Closed");
        require(allowList[msg.sender], "You are not on the allow list");
        // allowlist mint price is 0.001
        require(msg.value == 0.001 ether, "Not Enough Funds");
        internalMint();
    }
    
    // Add payment
    function publicMint() public payable {
        require(publicMintOpen, "Public Mint Closed");
        // public mint price is 0.01
        require(msg.value == 0.01 ether, "Not Enough Funds");
        internalMint(); // call function to handle internal
    }

    function internalMint() internal {
        // Add limiting supply, Total Supply keeps track of what has been minted
        require(totalSupply() < maxSupply, "We Sold out!");
        // keeps track of how many token ids
        uint256 tokenId = _tokenIdCounter.current(); 
        _tokenIdCounter.increment();
        // minter is sender wallet address
        _safeMint(msg.sender, tokenId);

    }
    // get balance of contract and and transfer it to address specified
    function withdraw(address _addr) external onlyOwner {
        // get the balance of the contract
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);

    }

    // Populate the allowList
    function setAllowList(address[] calldata addresses) external onlyOwner {
        //append addresses in array into allowList mapping, set value to true
        for(uint256 i=0; i < addresses.length; i++){
            allowList[addresses[i]] = true;
        }

    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

// Deploy
// Contract Address:  0x914206bd451bcdf30e1c4241496239dae7c5deae
// https://goerli.etherscan.io/tx/0x8850976f299eefb79fffdb582f59a1455d7a70f32b1046c34ed8c7b1ea2b0268

// editMintWindow, true, true  transact
//  https://goerli.etherscan.io/tx/0xc15e7ed9a9d34e85c17c7e64a4c7cc686cfd98e629f88d794693e743c971073d

// PublicMint
// Value: 10000000 Gwei
//   0x914206bd451bcDF30e1C4241496239daE7C5deAe
// https://goerli.etherscan.io/tx/0x6c374d640a69bc74dc44136f9251cd8e8f6f8db69225215229f3226f16d6b29e

//OpenSea Testnet   
// 0x914206bd451bcDF30e1C4241496239daE7C5deAe
// https://testnets.opensea.io/assets?search[query]=0x914206bd451bcDF30e1C4241496239daE7C5deAe

