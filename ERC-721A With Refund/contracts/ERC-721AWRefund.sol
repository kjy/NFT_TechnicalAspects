// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/ERC721A.sol";
import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/IERC721R.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Web3Builders is ERC721A, Ownable {

    uint256 public constant mintPrice = 1 ether;
    uint256 public constant maxMintPerUser = 5;
    uint256 public constant maxMintSupply = 100;

    uint public constant refundPeriod = 3 minutes;
    uint256 public refundEndTimeStamp;

    address public refundAddress;


    
    // different timestamps per id, NFT
    mapping(uint256 => uint256) public refundEndTimestamps;
    // end time per user
    // uint256 public refundEndTimestamp;
    // track who has refunded or not
    mapping(uint256 => bool) public hasRefunded;

    constructor() ERC721A("Web3Builders", "WE3") {
        refundAddress = address(this);
        refundEndTimeStamp = block.timestamp + refundPeriod;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmbseRTJWSsLfhsiWwuB2R7EtN93TxfoaMz1S5FXtsFEUB/";
    }

    function safeMint(uint256 quantity) public payable {
        require(msg.value >= mintPrice * quantity, "Not enough funds.");
        require(_numberMinted(msg.sender ) + quantity <= maxMintPerUser, "Mint Limit");
        require(_totalMinted() <= maxMintSupply, "Supply Exceed. Sold out.");

        _safeMint(msg.sender, quantity);
        refundEndTimeStamp = block.timestamp + refundPeriod;
        for(uint256 i=_currentIndex - quantity; i < _currentIndex; i++) {
            refundEndTimestamps[i] = refundEndTimeStamp;
        }

    }

    function refund(uint256 tokenId) external {
        require(block.timestamp < getRefundDeadline(tokenId), "Refund Period Expired.");
        // verify owner of NFT
        require(msg.sender == ownerOf(tokenId), "Not your NFT");
        uint256 refundAmount = getRefundAmount(tokenId);

        // transfer ownership of NFT
        _transfer(msg.sender, refundAddress, tokenId);

        // mark refunded
        hasRefunded[tokenId] = true;

        // refund the price
        Address.sendValue(payable(msg.sender), refundAmount);
    }

    function getRefundDeadline(uint256 tokenId) public view returns(uint256) {
        if(hasRefunded[tokenId]) {
            return 0;
        }
        return refundEndTimestamps[tokenId];
    }

    function getRefundAmount(uint256 tokenId) public view returns(uint256) {
        if(hasRefunded[tokenId]) {
            return 0;
        }
        return mintPrice;
    }

    function withdraw() external onlyOwner {
        require(block.timestamp > refundEndTimeStamp, "It's not past the refund period");
        uint256 balance = address(this).balance;
        // send value to msg.sender
        Address.sendValue(payable(msg.sender), balance);
    }
}

// Soldiity compiler, Advanced Configurations, Engable optimzation 200 checked, optimize gas fees
// balanceof, put in 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,      0: uint256: 2
// tokenURI, 0,   ipfs://QmbseRTJWSsLfhsiWwuB2R7EtN93TxfoaMz1S5FXtsFEUB/0

// deploy
// safeMint, 5 transact
// totalSupply,     0:uint256: 5
//tokenURI, 0,      0:string: ipfs://QmbseRTJWSsLfhsiWwuB2R7EtN93TxfoaMz1S5FXtsFEUB/0
// refundEndTimeStamp, 0,      0: uint256: 1692023703
// refund, tokenid = 0, "Refund Period Expired.".

// withdraw, from: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 , to: Web3Builders.withdraw()  0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B
