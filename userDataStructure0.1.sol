pragma solidity ^0.4.17;

contract userData{

    struct ledger{
        string userID;
        uint256 dataUsage;
        bool paid;
    }

    struct User{
        string userID;
        ledger[] guests;
        ledger[] hosts;
    }

    mapping(string=>address) public userEtherBase;//userID=>ethereum address
    mapping(string=>uint256) public userTokenBalance;//userID=>datatoken balance

    User[] public Users;

}