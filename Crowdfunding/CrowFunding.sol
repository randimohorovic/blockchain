// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFund {
    
    address public owner;
    uint public goal;
    uint public deadline;
    uint public totalRaised;
    bool public goalReached;
    bool public fundsWithdrawn;

    mapping(address => uint) public contributions;

    event Donation(address indexed donor, uint amount);
    event FundsWithdrawn(address indexed owner, uint amount);
    event RefundIssued(address indexed donor, uint amount);

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Samo vlasnik moze pozvati ovu funkciju");
        _;
    }

    modifier campaignActive() {
        require(block.timestamp < deadline, "Kampanja je zavrsila");
        _;
    }

    modifier campaignEnded() {
        require(block.timestamp >= deadline, "Kampanja jos traje");
        _;
    }

    constructor(uint _goal, uint _durationMinutes) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationMinutes * 1 minutes);
        totalRaised = 0;
        goalReached = false;
        fundsWithdrawn = false;
    }

    
    function donate() external payable campaignActive {
        require(msg.value > 0, "Mora se poslati Ether");

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;

        emit Donation(msg.sender, msg.value);

        
        if(totalRaised >= goal) {
            goalReached = true;
        }
    }

   
    function withdrawFunds() external onlyOwner campaignEnded {
        require(goalReached, "Cilj nije postignut");
        require(!fundsWithdrawn, "Sredstva su vec povucena");

        fundsWithdrawn = true;
        uint amount = address(this).balance;
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Povlacenje neuspjesno");

        emit FundsWithdrawn(owner, amount);
    }

    
    function refund() external campaignEnded {
        require(!goalReached, "Cilj je postignut, nema povrata");
        uint contributed = contributions[msg.sender];
        require(contributed > 0, "Nema nista za povrat");

        contributions[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: contributed}("");
        require(success, "Povrat neuspjesan");

        emit RefundIssued(msg.sender, contributed);
    }

    
    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    
    function getTimeLeft() external view returns (uint) {
        if(block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }
}
