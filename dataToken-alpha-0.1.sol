pragma solidity ^0.4.16;

//solidity conventions
//sender: the caller of a function. In remix IDE, sender address can be switched by altering account in the IDE before
//clicking a function block and triggering a js VM event (i.e. to run the corresponding function of current solidity code).
//sender address is globally callable via msg.sender

//DataToken contract conventions 
//user account: a user account means an Ether address with user name registered in this contract.

contract DataTokenAlpha {
    ////state variables////
    //Note down the creator of this contract.
    address public Creator = msg.sender;
    //define error content 
    string e_0_content = "The address is not registered as a user of this contract";
    //log event in blockchain when an account is created

    ////events////
    event AccountCreated(string _log, string _name, address _userName, string _words, uint256 _dataToken);
    //make an error log in blockchain
    event Error(string _content);
    //log down topUp : _account charged it's token wallet with _value unit is wei.
    event TopUp(string _account, uint256 _value);

    ////user state mapping////
    mapping(address=>bool) public isUser;
    mapping(address=>string) public userName;
    mapping(address=>bool) public sharingFlag;
    mapping(address=>bool) public buyingFlag;
    mapping(address=>uint256) public dataToken;
    
    ///host ledger chain mapping///
    mapping(address=>address) public Guest; //Host=>Guest
    mapping(address=>uint256) public DataUsage;//address here is the address of guest
    mapping(address=>bool) public feePaid;//address is guest
    
    ///guest ledger chain mapping///
    mapping(address=>address) public Host;//guest=>Host

    ////function////
    //on calling function createAccount, the caller Ether address will be linked to a userName specified by input
    //the work of this function is to create such a mapping relationship
    //then mark the caller address are a regitered address which in this context is to set "isUser" true.
    //finally the event of the creation of such account is logged into the blockchain used by this contract.
    //calling this function consumes gas payed by the sender account i.e. msg.sender.
    function createAccount(string _userName) payable public {
        //This function won't check whether the _userName is used before
        //what it cares is to link the caller's address to the specified userName
        //The user name is just a code name for other users to know there is a user with name blabla
        //the ecosystem don't really need a userName other than Ether Address
        //not implemented by solidity yet//userAddr[_userName] = _userName;//link userName with it's ether address
        userName[msg.sender] = _userName;//link userName with it's ether address reversely
        isUser[msg.sender] = true;//mark address _userName as user
        dataToken[msg.sender] = 0+msg.value;
        AccountCreated("user is created with name ",_userName,msg.sender,"\ntoken wallet is created with balance",dataToken[msg.sender]);
    }
    
    //top-up function
    function topUp() payable public {
        dataToken[msg.sender] += msg.value;//assign token to the account using msg.value due to payable function
    }
    
    //withdraw function
    function withdraw(uint256 _amount) public {
        //withdraw the money from the contract
        if(msg.sender.send(_amount)){
            dataToken[msg.sender] -= _amount;
        } else {
            revert();
        }
    }

    //quit function
    function 
    
    //availableSharing function will mark current account as "ready to share data service"
    //utilizing mapping relationship sharingFlag
    //A successful call wil mark current sender as seller that sharingFlag is true if the sender address
    //1. is a user i.e. is registered in this contranct that it has isUser = true;
    //2. is not currently buying shared data from other users that it's buyingFlag is not set.
    //otherwise the sharingFlag won't be set true and the function returns error message *not logging event*
    //if the account is a user account, a failure when setting sharingFlag true must due to it's buyingFlag state
    //buyingFlag is true means the sender is a buyer whoes position is not a qualified seller
    //if the account is *NOT* a user account, buyingFlag should be in no way set true, but the sender must
    //not be registered
    function availableSharing() public returns(string) {
        if (isUser[msg.sender]&&!buyingFlag[msg.sender]) {
            //if the caller of this function is a user's ethereum address
            sharingFlag[msg.sender] = true;
            return "Your status is changed to sharing.";
        } else {
            //if the ethereum address is not registered as a user with userName
            return "This address is not registered, call createAccount function first.";
        }
    }
    
    
    function askforSharing() public returns(string) {
        if (isUser[msg.sender]&&!sharingFlag[msg.sender]) {
            //if the caller is a user and is *NOT* sharing data as a seller
            buyingFlag[msg.sender] = true;
            return "Your stauts is changed to buying.";
        } else if (isUser[msg.sender]) {
            return "If you want to buy data, stop sharing first and try again.";
        } else if (!isUser[msg.sender]) {
            return "Your address is not registered in this contract, call createAccount first.";
        }
        
    }

  
    //stopSharing function should only work when a user account is at sharing state
    //thus the first distinguisher is whether the account is a user of this countract
    //the second condition is whether the account is sharing if it is a user
    //if it's sharing data, the function runs to make the sharingFlag false
    //otherwise the function do nothing with the flag and return corresponding error message.
    function stopSharing() public returns(string) {
        if (sharingFlag[msg.sender]) {
            sharingFlag[msg.sender] = false;
            return "Operation complete. You are not sharing data now.";
        } else if (!isUser[msg.sender]) {
            return "Your address is not registered in this contract.";
            } else {
            return "You are currently not sharing data.";
        }
    }
    //filtering process of topBuying function works similarly to stopSharing function
    function stopBuying() public returns(string) {
        if (buyingFlag[msg.sender]) {
            buyingFlag[msg.sender] = false;
            return "Operation Complete. You are not buying data now.";
        } else if (!isUser[msg.sender]) {
            return "Your address is not resitered in this contrac.";
        } else {
            return "You are currently not buying data.";
        }
        
    }
    
    function discardContract() public returns(string) {
        if (msg.sender==Creator) {
            selfdestruct(Creator);
        } else {
            return "Message sender is not authorized to do this.";
        }
    }

    function contractBalance() constant public returns (uint256) {
        return this.balance;
    }
}

