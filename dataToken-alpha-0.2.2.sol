pragma solidity ^0.4.18;

contract DataTokenAlpha{
    //////////////////////////////////////
    //////////////////////////////////////
    //Contract variables
    //////////////////////////////////////
    enum State {NOTCONTRACTUSER, ISPROVIDER, ISRECEIVER, HAVENOTPAID}
    uint public v2weiRate = 1;
    address[] providers;
    userInfo[] users;
    struct userInfo{
        State Identification;
        address etherAddress;
        address provider;
        uint256 dataUsage;
        address[] receivers;
    }
    mapping (address=>uint256) public tokenBalance;
    mapping (address=>uint256) public providerIndex;//if Identification == PROVIDER, this should be a unique value (i.e. a non-zero value)
    mapping (address=>uint256) public userIndex;//if Identification != NOTCONTRACTUSER, this should be a unique value (i.e. a non-zero value)
    //////////////////////////////////////
    //End of Contract variables
    //////////////////////////////////////
    
    //////////////////////////////////////
    //Event (log of events)
    //////////////////////////////////////
    event modifierResult(string _report, uint _value);
    event functionCallResult (string _report);
    event tokenBalanceUpdate (string _report, uint256 _income);
    ////////////////////////////////////////////////////////////////////////////
    //End of Event (log of events) definition
    ////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////
    //Initializer
    ////////////////////////////////////////
    function DataTokenAlpha() public {
        //initialize index 0 in Info array
        userIndex[this] = users.length;//index of the element created by push operation is array length naturally
        users.push(userInfo(State.ISRECEIVER,this,0,0,new address[](0x0)));
        //manually creating a default provider for testing purpose
        userIndex[0xdd870fa1b7c4700f2bd7f44238821c26f7392148]= users.length;
        users.push(userInfo(State.ISPROVIDER,0xdd870fa1b7c4700f2bd7f44238821c26f7392148,0x0,0,new address[](0x0)));
        providerIndex[0xdd870fa1b7c4700f2bd7f44238821c26f7392148] = providers.length;
        providers.push(0xdd870fa1b7c4700f2bd7f44238821c26f7392148);
    }
    ////////////////////////////////////////
    //End of Initializer
    ////////////////////////////////////////
    
    ////////////////////////////////////////
    //Modifiers
    ////////////////////////////////////////
        //
        //isNotContractUser modifier: to check if the user is currently not a user of DataTokenAlpha
        //
        modifier isNotContractUser() {
        if(users[userIndex[msg.sender]].Identification == 0){
            if(userIndex[msg.sender] != 0){
                modifierResult("This address was a user of DataToken", userIndex[msg.sender]);
                users[userIndex[msg.sender]].Identification = ISRECEIVER;
                functionCallResult("Contract user identity is recovered, welcome back.");
            } else {
                _;
            }
        }else{
            modifierResult("This address has been registered",users[userIndex[msg.sender]].Identification);
        }
        }
        //
        //isProvider check, to be more readable, the name is "isNotReceiver"
        //
        modifier isProvider() {
            if (users[userIndex[msg.sender]].Identification == 1){
                _;
            } else {
                modifierResult("The caller is not a provider",users[userIndex[msg.sender]].Identification);
            }
        }
        //
        //isReceiver check
        //
        modifier isReceiver() {
            if (users[userIndex[msg.sender]].Identification == 2){
                modifierResult("The caller is a receiver.");
                _;    
            } else {
                modifierResult("The caller is not a receiver");
            }
        }
        //
        //haveNotPaid check
        //
        modifier haveNotPaid() {
            if (users[userIndex[msg.sender]].Identification == 3){
                modifierResult("The caller have not paid last bill", users[userIndex[msg.sender]].Identification);
                _;
            }else{
                modifierResult("The caller have paid last bill", users[userIndex[msg.sender]].Identification);
            }
        }
    ////////////////////////////////////////
    //End of Modifier Definitions
    ////////////////////////////////////////


    //add current message sender to user list if it is not in the list.
    function addUser()
    isNotContractUser
    public
    {
        userIndex[msg.sender] = users.length;
        users.push(userInfo(State.ISRECEIVER,msg.sender,0,0,new address[](0x0))));
        
    }
    //remove current message sender from the user list if it were in it.
    function removeUser() isUser public{
        isNotNew[msg.sender]=false;
        userOperationResult("The user is marked as not using this contract.");
    }
    
    //
    //topUp function: sender must input a non-zero value (Ether)
    //current setting: 1 Ether = 1000 token
    function topUp() isUser payable public {
        Info[index[msg.sender]].tokenBalance+=msg.value;
        //event log 
        userBalanceUpdate("Exchanged this many of token from Ether: ",Info[index[msg.sender]].tokenBalance);
    }
    
    //
    //withdraw Ether from this contract
    //redeem Ether using all token of current user.
    //msg.sender will pay for this send() operation, which is undertaken by Ethereum network.
    function withdraw() isUser public {
        if(msg.sender.send(Info[index[msg.sender]].tokenBalance)){
            userBalanceUpdate("Withdraw operation has succeeded, redeemed amount of wei:", Info[index[msg.sender]].tokenBalance);
            Info[index[msg.sender]].tokenBalance=0;
        } else {
            revert();
            userBalanceUpdate("Withdraw operation has faild and all changes are reverted",0);
        }
    }
    
    //
    //function transfer token in side this contract
    //
    function transfer(address _provider, address _receiver, uint256 _amount) isUser public {
        if(Info[index[_receiver]].tokenBalance - _amount >= 0){
        Info[index[_receiver]].tokenBalance -= _amount;
        Info[index[_provider]].tokenBalance += _amount;
        //delete the value of provider after a complete payment
        Info[index[_receiver]].provider=0;
        //paid is true by default, so there is no need to change 
        //event log
        userBalanceUpdate("Token transfer from receiver to provider, amount:",_amount);
        } else {
            userBalanceUpdate("Token transfer failed, not enough token in receiver account, transfer value:",_amount);
            Info[index[_provider]].paid = false;
        }
    }
    //
    //Charge the data receiver after using.
    //
    //input of pay should be from userInfo (Info[]) of msg.sender
    //there should be a interface of this contract to assign volume of msg.sender
    function pay(address _provider, uint256 _volume) isReceiver public {
        transfer(_provider, msg.sender, _volume*v2weiRate);
    }
   //
   //link the msg.sender to a provider in provider list
   //
   function link()
   isReceiver 
   public
   {
       for(uint i=0; i <= providers.length; i++)
       {
         if(Info[index[providers[i]]].receiver.length < 5 && providers[i] != 0){
            Info[index[providers[i]]].receiver.push(msg.sender);
            Info[index[msg.sender]].provider = providers[i];
            userOperationResult("Provider and receiver are paired.");
            break;
         }
         if(i==providers.length){
            userOperationResult("No provider is available now.");
         }
       }
   }
//////////////////////////////////////////////////
    //function for test
    function contractBalance() constant public returns (uint256 ) {
        return this.balance;
    }
    function giveToken(uint256 _amount) 
    public
    {
        Info[index[msg.sender]].tokenBalance+=_amount;
        userBalanceUpdate("This many token is given to current message sender: ",_amount);
    }
    function suProvider() 
    isReceiver 
    public
    {
        Info[index[msg.sender]].userRole = true;
        providers.push(msg.sender);
        pIndex[msg.sender] = providerIndx;
        providerIndx += 1;
        userOperationResult("You have succeessfully turned to be provider.");
    }
    function suReceiver()
    isNotReceiver
    public
    {
        Info[index[msg.sender]].userRole = false;
        delete providers[pIndex[msg.sender]];
        userOperationResult("You have succeessfully turned to be receiver.");  
    }
    function chv2weiRate(uint _newRate) 
    public
        {
        v2weiRate = _newRate;
    }
    function usersLengthGetter()
    constant
    public
    returns(uint256)
    {
        return users.length;
    }
    
    //end of test function
/////////////////////////////////////////////////

    
}