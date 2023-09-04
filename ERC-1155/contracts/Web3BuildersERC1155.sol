// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract Web3Builders is ERC1155, Ownable, Pausable, ERC1155Supply, PaymentSplitter {
    uint256 public publicPrice = 0.02 ether;
    uint256 public allowListPrice = 0.01 ether;
    uint256 public maxSupply = 20;
    uint public maxPerWallet = 3;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = true;

    mapping(address => bool) allowList;
    mapping(address => uint256) purchasesPerWallet;

    constructor(address[] memory _payees, uint256[] memory _shares)
        ERC1155("ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/")
        PaymentSplitter(_payees, _shares)
{}

    // Create an edit function that will edit the mitn windows
    function editMintWindows(bool _publicMintOpen, bool _allowListMintOpen) external onlyOwner{
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    // Create a function to set the allowList
    function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint256 i=0; i < addresses.length; i++) {
            allowList[addresses[i]] = true;
        }
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    

    function allowListMint(uint256 id, uint256 amount) public payable {
        require(allowListMintOpen, "Allow List mint is closed.");
        require(allowList[msg.sender], "You are not on the allowList");
        mint(id, amount);
    }

    // add supply tracking - how many have been minted
    function publicMint(uint256 id, uint256 amount) public payable  {
        require(publicMintOpen, "Public mint closed.");
        require(id < 2, "Sorry looks like you are trying to mint the wrong NFT.");
        require(msg.value == publicPrice * amount, "Wrong! Not enough money sent.");
        mint(id,amount);
    }

    function mint(uint256 id, uint256 amount) internal {
        require(purchasesPerWallet[msg.sender] + amount <=maxPerWallet, "Wallet limit reached");
        require(id < 2, "Sorry looks like you are trying to mint the wrong NFT.");
        require(msg.value == allowListPrice * amount);
        require(totalSupply(id) + amount <= maxSupply, "Sorry we have minted out!");
        _mint(msg.sender, id, amount, "");
        purchasesPerWallet[msg.sender] += amount;

    }

    function withdraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance; // get the balance from the smart contract
        payable(_addr).transfer(balance);
    }

    function uri(uint256 _id) public view virtual override returns (string memory) {
        require(exists(_id), "URI: nonexistent token");

        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}

// Deployed contract created
// https://goerli.etherscan.io/tx/0x825408d2e19c8f38f60c9ac2251e767bf21d1a0954b2b2d2dbb59a5430d42e40
// Mint id:0, amount: 1
// https://goerli.etherscan.io/tx/0xc1cdeab823d9fd040585d94b74da38de8e71d777c081a8c7b5c2b8329c89c235
// OpenSea Testnet
// https://testnets.opensea.io/assets/goerli/0xd9c9178f30b619b4a4a96df5a74a72ec32aa3069/0
// withdraw function, balance is 0
// https://goerli.etherscan.io/tx/0x9ae627243e28c52e802503fa4beba624d770bd88aff1e717f261243d7d35283f
// allowListMint
// https://goerli.etherscan.io/tx/0xa8e013a84f699060e057c6abb0ed8d80b58da4a16c6e9b244328aaac9ea3b870
// publicMint
// https://goerli.etherscan.io/tx/0x881dde4a91e0995cc27e65c4507ce3653c69f03e16d6b42bd91415f46e227335


// Contract created after Payment Splitter in constructor
// Deploy, specify to _payees addresses ["0x147F347ced59C0fd5281Fc831Ad35fF2D2e1AE23", "0x1145BC8530b27E63bFBaCDe7971ce2F922c79764"]
// and _shares [10,90]
// https://goerli.etherscan.io/tx/0x65c12890a7ba8ce567375c86bbb1d0fbf4e321bb0da9c4dde488a4b154074ade

// editMintWindows function, publicMintOpen = true, allowList = false
// https://goerli.etherscan.io/tx/0xb59a978cb913ffe3afa4785d9468c2256309d55817eaaba384156fefdfb7e332

// value 60000000 gwei, publicMint id=0, amount = 3

