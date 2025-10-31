// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract StudentRecord {
    struct Student{
        string name;
        uint grade;
    }

    mapping (uint => Student) public students;
    uint public count;

    function addStudent(string memory _name, uint _grade) public { // _name udnerscore da nema konfilkra izmedu imena ako se jos engdje koristi
        count++;
        students[count] = Student(_name, _grade);
    }

   function getStudent(uint _id) public view returns (string memory, uint) {
    Student memory s = students[_id];
    return (s.name, s.grade);
    }

    //vjezba
    function updateGrade(uint _id, uint _grade) public {
        require(_id > 0 && _id <= count, "student ne postoji");
        students[_id].grade = _grade;

    }

}