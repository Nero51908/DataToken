pragma solidity ^0.4.16;

contract DataTokenAlpha{
    struct userInfo{
        address etherAdd; //ethereum address to top up the account or withdraw
        bool userRole; //1:is a provider; 0:is a receiver
        uint256 tokenBalance;//token balance 
        
    }
    //event to report whether an operation is done correctly.
    event userOperationResult (string _report);
    uint256 public userIndx=1;
    mapping (address=>bool) public isNotNew;
    mapping (address=>uint256) public index;
    userInfo[] public Info;
    //
    //Initializer
    //
    function DataTokenAlpha() public {
            Info.push(userInfo(this,false,0));
    }
    //
    //end of Initializer
    //
        //check if the user is currently not a user
        modifier isNew() {
        if(!isNotNew[msg.sender]){
            _;
        }else{
            userOperationResult("This address has been registered");
            getter_this_is_not_new;
        }
        }
        //check if the user is currently a user
        
        modifier isUser() {
            if(isNotNew[msg.sender]){
                _;
                userOperationResult("This is a user.");
            }else{
                userOperationResult("This address is not a user.");
            }
            
        }
    //getter function to tell the value of isNotNew mapping
    function getter_this_is_not_new() constant public returns(bool) {
        return isNotNew[msg.sender];
    }
    //add current message sender to user list if it is not in the list.
    function addUser() isNew public {
        
        if(index[msg.sender]==0){
        //do this with a complete new address
        Info.push(userInfo(msg.sender,false,0));
        isNotNew[msg.sender]=true;
        index[msg.sender]=userIndx;
        userIndx+=1;
        userOperationResult("A new user is added.");
        } else {
            //do this with an address which was a user of this contract.
            isNotNew[msg.sender]=true;
            userOperationResult("User information is recoverd.");
        }

    }
    //remove current message sender from the user list if it were in it.
    function removeUser() isUser public{
        isNotNew[msg.sender]=false;
        userOperationResult("The user is marked as not using this contract.");
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