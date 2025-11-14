// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiCrowdFund {

    struct Campaign {
        string title;
        address owner;
        uint goal;
        uint deadline;
        uint totalRaised;
        bool goalReached;
        bool fundsWithdrawn;
        mapping(address => uint) contributions;
    }

    uint public campaignCount;
    mapping(uint => Campaign) private campaigns;

    
    event CampaignCreated(uint indexed campaignId, string title, uint goal, uint deadline);
    event Donation(uint indexed campaignId, address indexed donor, uint amount);
    event FundsWithdrawn(uint indexed campaignId, address indexed owner, uint amount);
    event RefundIssued(uint indexed campaignId, address indexed donor, uint amount);

   
    function createCampaign(string memory _title, uint _goal, uint _durationMinutes) external {
        uint campaignId = campaignCount;
        campaignCount++;

        Campaign storage c = campaigns[campaignId];
        c.title = _title;
        c.owner = msg.sender;
        c.goal = _goal;
        c.deadline = block.timestamp + (_durationMinutes * 1 minutes);
        c.totalRaised = 0;
        c.goalReached = false;
        c.fundsWithdrawn = false;

        emit CampaignCreated(campaignId, _title, _goal, c.deadline);
    }

    
    function donateTo(uint _campaignId) external payable {
        require(block.timestamp < campaigns[_campaignId].deadline, "Kampanja je zavrsila");
        require(msg.value > 0, "Mora se poslati Ether");

        campaigns[_campaignId].contributions[msg.sender] += msg.value;
        campaigns[_campaignId].totalRaised += msg.value;

        if (campaigns[_campaignId].totalRaised >= campaigns[_campaignId].goal) {
            campaigns[_campaignId].goalReached = true;
        }

        emit Donation(_campaignId, msg.sender, msg.value);
    }

    
    function withdrawFunds(uint _campaignId) external {
        require(msg.sender == campaigns[_campaignId].owner, "Samo vlasnik moze povuci sredstva");
        require(block.timestamp >= campaigns[_campaignId].deadline, "Kampanja jos traje");
        require(campaigns[_campaignId].goalReached, "Cilj nije postignut");
        require(!campaigns[_campaignId].fundsWithdrawn, "Sredstva su vec povucena");

        campaigns[_campaignId].fundsWithdrawn = true;
        uint amount = campaigns[_campaignId].totalRaised;
        (bool success, ) = campaigns[_campaignId].owner.call{value: amount}("");
        require(success, "Povlacenje neuspjesno");

        emit FundsWithdrawn(_campaignId, campaigns[_campaignId].owner, amount);
    }

    
    function refund(uint _campaignId) external {
        require(block.timestamp >= campaigns[_campaignId].deadline, "Kampanja jos traje");
        require(!campaigns[_campaignId].goalReached, "Cilj je postignut, nema povrata");

        uint contributed = campaigns[_campaignId].contributions[msg.sender];
        require(contributed > 0, "Nema nista za povrat");

        campaigns[_campaignId].contributions[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: contributed}("");
        require(success, "Povrat neuspjesan");

        emit RefundIssued(_campaignId, msg.sender, contributed);
    }

    
    function getCampaign(uint _campaignId) external view returns (
        string memory title,
        address owner,
        uint goal,
        uint deadline,
        uint totalRaised,
        bool goalReached,
        bool fundsWithdrawn
    ) {
        Campaign storage c = campaigns[_campaignId]; 
        return (
            c.title,
            c.owner,
            c.goal,
            c.deadline,
            c.totalRaised,
            c.goalReached,
            c.fundsWithdrawn
        );
    }

    
    function getTimeLeft(uint _campaignId) external view returns (uint) {
        if(block.timestamp >= campaigns[_campaignId].deadline){
            return 0;
        }
        return campaigns[_campaignId].deadline - block.timestamp;
    }
}
