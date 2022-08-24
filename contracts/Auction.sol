// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC721
{
    function transferFrom(
        address from,
        address to,
        uint256 nftId
    ) external;
}

/**
 * @dev An auction contract for ERC-721 NFT tokens.
 * A seller sets a starting price and an ending time. At the end of
 * the auction the highest bidder wins.
 */
contract Auction
{
    /**
     * Events
     */
    event Start();
    /**
     * State Variables
     */
    // NFT will only be set once on creation
    IERC721 public immutable nft;
    // ID of the NFT
    uint256 public immutable nftId;
    // The seller of the NFT
    address payable public immutable seller;
    // Ending time in Unix time of the auction
    // uint32 can hold up to 100 years from now
    uint32 public endAt;
    // Set to true when the auction starts
    bool public started;
    // Set to true when the auction ends
    bool public ended;
    // Address of the highest bidder
    address public highestBidder;
    // Amount of the highest bid
    uint256 public highestBid;
    // to hold the bids that all bidders have made
    // bidder address -> amount
    mapping(address => uint256) public bids;

    constructor(
        address _nft,
        uint256 _nftId,
        uint256 _startingBid
    )
    {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        highestBid = _startingBid;
    }

    function start() external
    {
        // only the seller of the NFT can start the auction
        require(msg.sender == seller, "not seller");
        // can't call this function if the auction has already started
        require(!started, "already started");

        started = true;
        // block.timestamp is a uint256, cast it to uint32
        // auction will end 7 days from call of start function
        endAt = (uint32(block.timestamp) + 7 days);

        // transfer the NFT from the seller to the addrses of this contract
        nft.transferFrom(seller, address(this), nftId);

        emit Start();
    }
}