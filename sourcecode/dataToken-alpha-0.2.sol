pragma solidity ^0.4.16;

contract DataTokenAlpha{
    //////////////////////////////////////
    //Test variables
    //////////////////////////////////////
    //provider list
    address[] public providers;//nearby providers.
    //////////////////////////////////////
    //End of test variables
    //////////////////////////////////////
    
    ////////////////////////////////////////
    //Contract variables
    ////////////////////////////////////////
    uint public v2weiRate = 1;
    
    struct userInfo{
        address etherAdd; //ethereum address to top up the account or withdraw
        bool userRole; //1:is a provider; 0:is a receiver
        uint256 tokenBalance;//token balance 
        //ledger
        address provider;
        address receiver;
        uint256 volume;
        bool paid;
    }
    //event to report whether an operation is done correctly.
    event userOperationResult (string _report);//result of adding or removing users.
    event userBalanceUpdate (string _report, uint256 _income);
    uint256 public userIndx = 1;
    uint256 public providerIndx = 1;
    mapping (address=>bool) public isNotNew;//whether is contract user flag
    mapping (address=>uint256) public index;//contract user index
    mapping (address=>uint256) public pIndex;//provider index
    userInfo[] public Info;//user inforamtion array
    ////////////////////////////////////////
    //End of Contract variables
    ////////////////////////////////////////
    
    ////////////////////////////////////////
    //Initializer
    ////////////////////////////////////////
    //1. Contract user array will hold information of the contract itself
    //2. Private address 0xdd870fa1b7c4700f2bd7f44238821c26f7392148 is defined as user 
    //3. This first private address user is marked as provider for testing purposes
    //4. Contract user index [0] and [1] are used after this initialization
    function DataTokenAlpha() 
    public 
    {
        //initialize index 0 in Info array
        Info.push(userInfo(this,false,0,0,0,0,true));
        ///////////////////////////////////////////////////////////
        //manually creating a default provider for testing purpose
        ///////////////////////////////////////////////////////////
        Info.push(userInfo(0xdd870fa1b7c4700f2bd7f44238821c26f7392148,true,0,0,0,0,true));
        index[0xdd870fa1b7c4700f2bd7f44238821c26f7392148]= userIndx;
        userIndx += 1;
        providers.push(0xdd870fa1b7c4700f2bd7f44238821c26f7392148);
    }
    ////////////////////////////////////////
    //End of Initializer
    ////////////////////////////////////////
    ////////////////////////////////////////
    ////////////////////////////////////////
    //Modifiers Definitions
    ////////////////////////////////////////
        //
        //isNew modifier: to check if the user is currently not a user
        //
        modifier isNew() {
        if(!isNotNew[msg.sender]){
            _;
        }else{
            userOperationResult("This address has been registered");
            getter_this_is_not_new;
        }
        }
        //
        //isUser modifier: to check if the user is currently a user
        //
        modifier isUser() {
            if(isNotNew[msg.sender]){
                _;
                userOperationResult("This is a user.");
            }else{
                revert();
                userOperationResult("This address is not a user.");
            }
        }
        //
        //isProvider check, to be more readable, the name is "isNotReceiver"
        //
        modifier isNotReceiver() {
            if (Info[index[msg.sender]].userRole){
                _;
            } else {
                
            }
        }
        //
        //isReceiver check
        //
        modifier isReceiver() {
            if (isNotNew[msg.sender]&&!Info[index[msg.sender]].userRole){
                userOperationResult("This is a receiver.");
                _;    
            } else {
                userOperationResult("This is not a receiver");
            }
        }
        //
        //
        //
            
        
    //getter function to tell the value of isNotNew mapping
    function getter_this_is_not_new() 
    constant 
    public
    returns(bool) 
    {
        return isNotNew[msg.sender];
    }
    //add current message sender to user list if it is not in the list.
    function addUser() 
    isNew 
    public 
    {
        
        if(index[msg.sender]==0){
        //do this with a complete new address
        Info.push(userInfo(msg.sender,false,0,0,0,0,true));
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
    function removeUser()
    isUser 
    public
    {
        isNotNew[msg.sender]=false;
        userOperationResult("The user is marked as not using this contract.");
    }
    
    //
    //topUp function: sender must input a non-zero value (Ether)
    //current setting: 1 Ether = 1000 token
    function topUp() 
    isUser 
    payable 
    public 
    {
        Info[index[msg.sender]].tokenBalance+=msg.value;
        //event log 
        userBalanceUpdate("Exchanged this many of token from Ether: ",Info[index[msg.sender]].tokenBalance);
    }
    
    //
    //withdraw Ether from this contract
    //redeem Ether using all token of current user.
    //msg.sender will pay for this send() operation, which is undertaken by Ethereum network.
    function withdraw() 
    isUser 
    public 
    {
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
    function transfer(address _provider, address _receiver, uint256 _amount) 
    isUser 
    public 
    {
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
    function pay(address _provider, uint256 _volume) 
    isReceiver 
    public 
    {
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
         if(Info[index[providers[i]]].receiver == 0 && providers[i] != 0){
            Info[index[providers[i]]].receiver = msg.sender;
            Info[index[msg.sender]].provider = providers[i];
            userOperationResult("Provider and receiver are paired.");
            break;
         }
         if(i==providers.length){
            userOperationResult("No provider is available now.");
         }
       }
   }
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
    //function for test
    //change wei=>token rate
    function chv2weiRate(uint _newRate)
    public 
    {
        v2weiRate = _newRate;
    }
    //getter of contract balance
    function contractBalance() 
    constant 
    public 
    returns (uint256 ) 
    {
        return this.balance;
    }
    //give _amount token to messagee sender
    function giveToken(uint256 _amount) 
    public
    {
        Info[index[msg.sender]].tokenBalance+=_amount;
        userBalanceUpdate("This many token is given to current message sender: ",_amount);
    }
    //switch user role flag when user is currently a receiver 
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
    //switch user role flag when user is curretnly a provider
    function suReceiver()
    isNotReceiver
    public
    {
        Info[index[msg.sender]].userRole = false;
        delete providers[pIndex[msg.sender]];
        userOperationResult("You have succeessfully turned to be receiver.");  
    }
    //end of test functions
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
    
}