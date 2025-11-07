// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract StudentRecord {
    struct Student{
        string name;
        uint grade;
    }
    
    address public owner;
    constructor() payable {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "niste vlasnik");
        _;
    }

    mapping (uint => Student) public students;
    uint public count;

    //vjezba 3
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function transfer(address _to, uint _amount) public {
        require(balances[msg.sender] >= _amount, "nemate dovoljno sredstava");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }


    function addStudent(string memory _name, uint _grade) public onlyOwner{ // _name udnerscore da nema konflikta izmedu imena ako se jos negdje koristi
        count++;
        students[count] = Student(_name, _grade);
    }

   function getStudent(uint _id) public view returns (string memory, uint) {
    Student memory s = students[_id];
    return (s.name, s.grade);
    }

    function updateGrade(uint _id, uint _grade) public onlyOwner{
        require(_id > 0 && _id <= count, "student ne postoji");
        students[_id].grade = _grade;

    }
    
    function getBalance(address _user) public view returns (uint) {
        return balances[_user];
    }




}