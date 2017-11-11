pragma solidity ^0.4.16;

contract DataTokenAlpha{
    struct userInfo{
        address etherAdd; //ethereum address to top up the account or withdraw
        bool userRole; //1:is a provider; 0:is a receiver
        uint256 tokenBalance;//token balance 
        
    }
   
    uint256 public userIndx=1;
    mapping (address=>bool) public isNotNew;
    mapping (address=>uint256) public index;
    userInfo[] public Info;
    function DataTokenAlpha() public {
            Info.push(userInfo(this,false,0));

    }
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
    
    function addUser() isNew public {
        
        Info.push(userInfo(msg.sender,false,0));
        isNotNew[msg.sender]=true;
        index[msg.sender]=userIndx;
        userIndx+=1;
    }
    
    //function public topUp() payable {
    //    
    //}
    
    //function for test
    function giveToken() public {
        Info[index[msg.sender]].tokenBalance+=10;
    }
    //end of test function
    

    
}