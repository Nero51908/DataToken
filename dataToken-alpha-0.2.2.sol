pragma solidity ^0.4.18;

contract DataTokenAlpha {
    //////////////////////////////////////
    //////////////////////////////////////
    //Contract variables
    //////////////////////////////////////
    enum State {NOTCONTRACTUSER, ISPROVIDER, ISRECEIVER, HAVENOTPAID}
    uint public v2weiRate = 1;
    address[] providers;
    userInfo[] users;
    struct userInfo {
        address etherAddress;
        address provider;
        uint256 dataUsage;
        address[] receivers;
    }
    mapping (address=>State) public Identification;
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
        users.push(userInfo(this,0,0,new address[](0x0)));
        Identification[this] = State.ISRECEIVER;
        //manually creating a default provider for testing purpose
        userIndex[0xdd870fa1b7c4700f2bd7f44238821c26f7392148] = users.length;
        users.push(userInfo(0xdd870fa1b7c4700f2bd7f44238821c26f7392148,0x0,0,new address[](0x0)));
        Identification[0xdd870fa1b7c4700f2bd7f44238821c26f7392148] = State.ISPROVIDER;
        providerIndex[0xdd870fa1b7c4700f2bd7f44238821c26f7392148] = providers.length;
        providers.push(0xdd870fa1b7c4700f2bd7f44238821c26f7392148);
    }
    ////////////////////////////////////////
    //End of Initializer
    ////////////////////////////////////////
    
    ////////////////////////////////////////
    //Modifiers
    ////////////////////////////////////////
    modifier isContractUser() {
        if(Identification[msg.sender] != State.NOTCONTRACTUSER)
        {
            _;
        }
    }
    modifier isGoodUser() {//user identification value is not HAVENOTPAID
        if(Identification[msg.sender] == State.ISPROVIDER || Identification[msg.sender] == State.ISRECEIVER)
        {
            _;
        }
    }
        //
        //isNotContractUser modifier: to check if the user is currently not a user of DataTokenAlpha
        //
        modifier isNotContractUser() {//this modifie will recover user identification of a new user who was a contract user
        if(Identification[msg.sender] == State.NOTCONTRACTUSER){
            if(userIndex[msg.sender] != 0){//"was a user" case
                modifierResult("This address was a user of DataToken", userIndex[msg.sender]);
                Identification[msg.sender] = State.ISRECEIVER;
                functionCallResult("Contract user identity is recovered, welcome back.");
            } else {//"completely new user" case
                _;
            }
        }else {
            //"currently is a user" case
            modifierResult("This address has been registered",uint8(Identification[msg.sender]));
        }
        }
        //
        //isProvider check, to be more readable, the name is "isNotReceiver"
        //
        modifier isProvider() {
            if (Identification[msg.sender] == State.ISPROVIDER){
                _;
            } else {
                modifierResult("The caller is not a provider",uint8(Identification[msg.sender]));
            }
        }
        //
        //isReceiver check
        //
        modifier isReceiver() {
            if (uint8(Identification[msg.sender]) == 2){
                modifierResult("The caller is a receiver.",uint8(Identification[msg.sender]));
                _;    
            } else {
                modifierResult("The caller is not a receiver",uint8(Identification[msg.sender]));
            }
        }
        //
        //haveNotPaid check
        //
        modifier haveNotPaid() {
            if (Identification[msg.sender] == State.HAVENOTPAID){
                modifierResult("The caller have not paid last bill", uint8(Identification[msg.sender]));
                _;
            }else {
                modifierResult("The caller have paid last bill", uint8(Identification[msg.sender]));
            }
        }
    ////////////////////////////////////////
    //End of Modifier Definitions
    ////////////////////////////////////////


    //add current message sender to user list if it is not in the list.
    //a special case that the message sender was a contract user and has suspended it's user identify in DataTOken Contract
    //the modifier isNotContractUser will detect such kind of ex-users and recover their contract user identity when they call addUser() function
    function addUser()
    isNotContractUser
    public
    {
        userIndex[msg.sender] = users.length;//the unique index for this user.
        users.push(userInfo(msg.sender,0,0,new address[](0x0)));//initialize user information
        Identification[msg.sender] = State.ISRECEIVER;
        functionCallResult("New user is created.");
    }
    //remove current message sender from the user list if it were in it.
    function removeUser() 
    isReceiver
    public
    {
        Identification[msg.sender] = State.NOTCONTRACTUSER;
        functionCallResult("Suspend: The user is marked as not using this contract.");
    }
    //switch user identification value to ISPROVIDER
    function suProvider() 
    isReceiver
    public
    {
        //was a provider case
        if(providerIndex[msg.sender] != 0){
            providers[providerIndex[msg.sender]] = msg.sender;
            Identification[msg.sender] = State.ISPROVIDER;
            functionCallResult("You have succeessfully turned to be a provider.");
        }else {
            //the first time to be a provider case
            providerIndex[msg.sender] = providers.length;
            providers.push(msg.sender);
            Identification[msg.sender] = State.ISPROVIDER;
            functionCallResult("You have succeessfully turned to be a provider.");
        }
    }
    function suReceiver()
    isProvider
    public
    {
        providers[providerIndex[msg.sender]] = 0x0;//remove address from providers(address[]) array
        Identification[msg.sender] = State.ISRECEIVER;
        functionCallResult("You have succeessfully turned to be a receiver.");  
    }
    //topUp function: sender must input a non-zero value (Ether)
    //current setting: 1 Ether = 1000 token
    function topUp() 
    isContractUser 
    payable 
    public 
    {
        tokenBalance[msg.sender] += (msg.value / v2weiRate);
        tokenBalanceUpdate("Exchanged this many of token from Ether: ",tokenBalance[msg.sender]);
    }
    
    //
    //withdraw Ether from this contract
    //redeem Ether using all token of current user.
    //msg.sender will pay for this send() operation, which is undertaken by Ethereum network.
    function withdraw() 
    isGoodUser 
    public 
    {
        if(msg.sender.send(tokenBalance[msg.sender])){
            tokenBalanceUpdate("Withdraw operation has succeeded, redeemed amount of wei:", tokenBalance[msg.sender] * v2weiRate);
            delete tokenBalance[msg.sender];
        } else {
            revert();
            tokenBalanceUpdate("Withdraw operation has faild and all changes are reverted", 0);
        }
    }
    
    //
    //function transfer token in side this contract
    //
    function transfer(address _sender, address _target, uint256 _amount)
    isContractUser
    public  
    returns(bool)
    {
        if (tokenBalance[msg.sender] - _amount >= 0){
        tokenBalance[_sender] -= _amount;
        tokenBalance[_target] += _amount;
        //delete the value of provider after a complete payment
        tokenBalanceUpdate("Token transfer finished, amount:",_amount);
        return true;
        } else {
            tokenBalanceUpdate("Token transfer failed, not enough token in receiver account, token not transferred:",_amount);
            return false;
        }
    }
   //
   //link the msg.sender to a provider in provider list
   //
   function link()
   isReceiver 
   public
   {
       //iteration to find a provier
       for (uint i = 0; i <= providers.length; i++)
       {
            //current version limit providers and reveivers are one on one pairs
            if (users[userIndex[providers[i]]].receivers.length < 2 && providers[i] != 0x0) {
            users[userIndex[providers[i]]].receivers.push(msg.sender);
            users[userIndex[msg.sender]].provider = providers[i];
            Identification[msg.sender] = State.HAVENOTPAID;
            functionCallResult("Provider and receiver are paired.");
            break;
            }
            if (i==providers.length) {
                functionCallResult("No provider is available now.");
            }
       }
   }
    //
    //Receiver need to call pay function to make themselves ISRECEIVER again, otherwise 
    //they will remain HAVENOTPAID Identification(Address=>State)
    //
    function pay() 
    haveNotPaid
    public 
    {
        if (transfer(msg.sender, users[userIndex[msg.sender]].provider, users[userIndex[msg.sender]].dataUsage))
        {
            users[userIndex[msg.sender]].dataUsage = 0;
            Identification[msg.sender] = State.ISRECEIVER;
            functionCallResult("Your bill is now paid.");
        } else {
            //payment did not succeed
            functionCallResult("Payment did not succeed.");
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
        tokenBalance[msg.sender] += _amount;
        tokenBalanceUpdate("This many token is given to current message sender: ", _amount);
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