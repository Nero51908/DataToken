pragma solidity ^0.4.16;


contract ArrayStructureExperiment{
    struct User{
          uint roleId;
        }
    
        mapping (string => User[]) companyUserMap;
    
        function addUser(string _key, uint _roleId)public returns(uint256){
            return companyUserMap[_key].push(User(_roleId));
        }
        
        function whtf() constant returns(uint){
            return companyUserMap["nero"][0].roleId;
        }
        
        function length() constant public returns(uint) {
            return companyUserMap["nero"].length;
        }
}