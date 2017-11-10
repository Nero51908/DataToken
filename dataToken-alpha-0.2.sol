pragma solidity ^0.4.16;

contract DataTokenAlpha{
    struct userInfo{
        address etherAdd; //ethereum address to top up the account or withdraw
        bool userRole; //1:is a provider; 0:is a receiver
        uint256 tokenBalance;//token balance 
        
    }
   
    uint256 public userIndx=0;
    mapping (address=>bool) public isNotNew;
    mapping (address=>uint256) public index;
    modifier isNew() {
        if(!isNotNew[msg.sender]){
            _;
        }else{
            getter_this_is_not_new;
        }
        }
    function getter_this_is_not_new() constant public returns(bool) {
        return isNotNew[msg.sender];
    }
    //function public topUp() payable {
    //    
    //}
    userInfo[] public Info;
    function addUser() isNew public {
        
        Info.push(userInfo(msg.sender,false,0));
        isNotNew[msg.sender]=true;
        index[msg.sender]=userIndx;
        userIndx+=1;
    }
    //function for test
    function giveToken(){
        Info[index[msg.sender]].tokenBalance+=10;
    }
    //end of test function
    

    
}