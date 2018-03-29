pragma solidity ^0.4.18;

contract DataTokenAlpha {
    address owner;
    //contract (token) properties
    string public tokenName = "dataToken";
    //
    uint public decimals = 9;
    uint256 initialSupply = 666;
    //the possible bigest number of coins (including non-integer valued coins)i.e. number of coins express by the smallest unit of this token
    uint256 totalSupply = initialSupply * 10 ** decimals;
    //APID counter, each new provider will be given this number. It's value updates by +1 after each give out (implemented in surProvider function).
    uint256 APID_counter = 1;
    //ethereum users can be receiver or provider. By defualt they are all receivers. by a successful call of surProvider, a user can be recognized as a provider.
    enum role {ISRECEIVER, ISPROVIDER, PAIRED}
    //token balance of each ethereum account. counted in totalSupply
    mapping (address => uint256) public balance;
    //role of an account, by default is role.ISRECEIVER
    mapping (address => role) public identification;
    //SSID format: DataToken_########; this mapping holds the suffix number shown as #####
    mapping (address => uint256) public APID;
    //find a provider by ssid it uses to share data service (SSID format: DataToken_########, ######## represents numerical ID of that provider)
    //This mapping can be private in release versions.
    mapping (uint256 => address) public providerBehind;
    //number of users under a provider
    mapping (address => uint) public numberOfUsers;
    //Receiver thus knows which address they should pay token.
    mapping (address => address) public providerOf;
    //pricing: value per MB
    mapping (address => uint256) public priceOf;
    //data usage recorded by provider and receiver
    mapping (address => mapping (address => uint256)) public usageOf;
    //wifi passwd of provider
    mapping (address => string) internal passwd;
    //provider's pocket// used in link() function
    mapping (address => mapping(address => bytes32)) internal providerPocket;     
    //transfer event infomation. value is 
    event Transfer(address _from, address _to, uint256 value);
    //switch user role event
    event Sur(address _user, role _newrole, bool success);
    /**
    *Constructor function
    *@constructor
    *contract has defaultly a provider for convenience of test
    */
    function DataTokenAlpha() public {
        owner = msg.sender;
        balance[owner] = totalSupply;
    }


    /**
    *internally defined transfer operation
    *transfer certain amount of token from one address to another address
    *this function is so powerful that it should not be accessable externally.
    *param {address} _from value sender
    *param {address} _to value receiver
    *param {uint256} _value value to be sent
    * _to is not 0x0 address
    * _from doesn't have enough token to transfer
    * token of _to will overflow after receiving the transfer
    * total balance of _to and _from has changed after this transfer operation will throw
    */
    function _transfer(address _from, address _to, uint256 _value)
    internal
    {
        //transfer to 0x0 means destroy such amount of token.
        require(_to != 0x0);
        //check if the sender has enough token
        require(balance[_from] >= _value);
        //check if balance of the recipient overflows (don't want overflow)
        require(balance[_to] + _value >= balance[_to]);
        //take a snapshot on total balance of both sides for assert check
        uint256 totalBalance = balance[_from] + balance[_to];
        //transfer operation
        balance[_from] -= _value;
        balance[_to] += _value;
        //assert function is used to check bugs during transfer operation. assert(false) will throw such tranfer.
        assert(balance[_from] + balance[_to] == totalBalance);
    }

    /**
    *tranfer that is called publicly
    *param {address} _to receiver of _value
    *param {uint256} _value value of token to transfer
    */
    function transfer(address _to, uint256 _value)
    public
    {
        _transfer(msg.sender, _to, _value);
    }

    /**
    *token seller function
    *
    *msg.sender buy token from owner address using Ether by naming value of the transaction when calling this function
    *this function is payable
    */
    function buyToken()
    payable
    public
    returns(bool success)
    {
        _transfer(owner, msg.sender, msg.value / 10 ** 9);
        return true;
    }

    /**
    *internally defined switch user role function
    *
    *has built-in check whether current role is allowed to switch
    *
    *param {address} _user address to make change on
    *param {role} _oldrole expected current role of message sender
    *param {role} _newrole targeted new role after a success call of this function
    *
    * current user role is not the required _oldrole
    */
    function _sur(address _user, role _oldrole, role _newrole)
    internal
    {
        if (identification[_user] == _oldrole) {
            identification[_user] = _newrole;
            if (identification[_user] == _newrole) {
                emit Sur(_user, _newrole, true);
            } else {
                emit Sur(_user, _newrole, false);
            }
        } else {
            emit Sur(_user, _newrole, false);
        }
    }

    /**
    *public function
    *
    *a receiver is switched to be a provider after a success call of this function
    *
    *param {uint256} _price price of wifi service in terms of token per 100 MB data
    *
    *@return {bool} success whether the function has finished successfully
    *@return {address} provider address of the function caller
    *
    * priceOf mapping is not changed by this function throw
    */
    function surProvider (uint256 _price, string _passwd)
    public
    returns(bool success, address provider)
    {
        _sur(msg.sender,role.ISRECEIVER,role.ISPROVIDER);
        priceOf[msg.sender] = _price;
        //note the password here is not the "password" to connect to Wi-Fi AP
        //but the key used to generate dynamic PIN by SHA3 together with blocktime as input
        passwd[msg.sender] = _passwd;
        if (APID[msg.sender] == 0) {
            //assign new provider an APID
            APID[msg.sender] = APID_counter;
            //with providerBehind[APID] user can find provider address with the APID 
            providerBehind[APID_counter] = msg.sender;
            APID_counter += 1;
        }
        assert(priceOf[msg.sender] == _price);
        return (true, msg.sender);
    }

    /**
    *public function
    *
    *a provider in idle is switched to be a receiver after a success call
    *
    *priceOf mapping is intackt from this function
    *
    *param {uint} _numberOfUsers current number of users under this provider's hot spot 
    *
    *@return {bool} success whether this fucntion has succeeded
    *
    * _numberOfUsers is not 0 i.e. this provider is not in idle
    */
    function surReceiver ()
    public
    returns(bool success)
    {
        require(identification[msg.sender] == role.ISPROVIDER);
        require(numberOfUsers[msg.sender] == 0);
        _sur(msg.sender, role.ISPROVIDER, role.ISRECEIVER);
        return true;
    }


    /**
    *internally defined estimation function
    */
    function _affordableData (address _wallet, uint256 _price)
    internal
    view
    returns (uint256 _volume)
    {
        return balance[_wallet] / _price;
    }

    /**
    *
    *public function that links message sender to the chosen provider
    *
    *This function will log address 
    *
    *message sender must be receiver
    *param providerBehind[_providerID] is the address of provider
    *(Suppose user interface can translate SSID to be address of provider and use that address as argument)
    *
    *affordable data is estimated in this function and the estimation is required to be larger than 1 (MB)
    *
    *role of message sender is changed to be PAIRED which means can call no function but payandleave()
    *
    *provider address is assigned to msg.sender for use of payment issuing and fetching passwd for wifi connection from mapping
    *
    *return messagesender address and estimation of it's max possible data usage
    *
    *when provider address is not assigned to message sender successfully, throw.
    *
    *when message sender role is not changed to be role.PAIRED, throw.
    */
    function link (uint256 _providerID, uint256 _yourkey)
    public
    returns(address receiver, bytes32 pwd)
    {
        //prerequiests
        require(identification[providerBehind[_providerID]] == role.ISPROVIDER);
        require(identification[msg.sender] == role.ISRECEIVER);
        require(_affordableData(msg.sender, priceOf[providerBehind[_providerID]]) >= 1);
        //change receiver identity to PAIRED
        identification[msg.sender] = role.PAIRED;
        //assign the provider address to receiver's mapping to establish the link
        providerOf[msg.sender] = providerBehind[_providerID];
        //add one use count to provider
        numberOfUsers[providerBehind[_providerID]] += 1;  
        //put a key in provider's pocket for frontend handshake
        providerPocket[providerBehind[_providerID]][msg.sender] = keccak256(block.timestamp + _yourkey);
        assert(providerOf[msg.sender] == providerBehind[_providerID]);
        assert(identification[msg.sender] == role.PAIRED);
        return (msg.sender, providerPocket[providerBehind[_providerID]][msg.sender]);
    }
    /**
    doorkeeper for providers
     */
    function doorKeeper (address _knocker, bytes32 _pwd)
    public
    returns(bool letIn)
    {
        //prerequiest
        require(identification[msg.sender] == role.ISPROVIDER);
        require(identification[_knocker] == role.PAIRED);
        //retreive the payload put by paired receiver during link()
        bytes32 tempkey = providerPocket[msg.sender][_knocker];
        //reset mapping value. this one-time password (token) is used and expired after this function
        //i.e. once any one try to connect the provider with the identity of the paired receiver
        //and the provider front checked with the contract via this only function
        //the password set by the paired receiver will be expired no matter the _knocker has provided the correct password or not.
        //to hijack a paired receiver address, the malicious user must send   
        delete providerPocket[msg.sender][_knocker];
        return tempkey == _pwd;
    }

    /**
    *function to record data usage
    *
    *param _usage data usage 
    *data usage is in terms of MB
    */
    function usageRecord (address _theOtherSide, uint256 _usage) 
    public
    returns (bool success)
    {
        usageOf[msg.sender][_theOtherSide] = _usage;
        return true;
    }

    /**
    *internal function
    *compare data usage record by both provider and receiver's devices
    *difference is smaller than tolerance will return true
    *
    *A problem is left for front implementation:
    *To let two devices send information to the contract about data usage.
    */
    function _tolerance (uint256 _range, uint256 _usageLimit)
    internal
    view
    returns (bool success)
    {
        uint256 _urPro = usageOf[providerOf[msg.sender]][msg.sender];
        uint256 _urRec = usageOf[msg.sender][providerOf[msg.sender]];
        require(_usageLimit > usageOf[providerOf[msg.sender]][msg.sender]);
        if (_urRec < _urPro) {
            return (_urPro - _urRec < _range);
        } else {
            return (_urRec - _urPro <= _range);
        }
    }

    //suspend receiver (message sender)
    //_sur(role.ISRECEIVER, role.PAIRED);

    /**
    *internally defined fee collector
    *has high authority
    *role.PAIRED will be recovered to be role.ISRECEIVER on succeed.
    */
    function _cashier (address _payer, uint256 _volume)
    internal
    returns (bool success)
    {
        //_sur PAIRED back to receiver
        _transfer(_payer, providerOf[_payer], _volume * priceOf[providerOf[_payer]]);
        _sur(msg.sender, role.PAIRED, role.ISRECEIVER);
        //if the payer has payed successfully, it's role should be receiver again after execution of this function
        assert(identification[_payer] == role.ISRECEIVER);
        return true;
    }

    /**
    *normal case used data < datalimit
    *pay function. 
    *
    *assume that tolerance of data usage error obtained by comparing both records is always satisfied (otherwise this function will never succeed)
    *
    */
    function payAndLeave (uint256 _range, uint256 _usageLimit)
    public
    returns (bool success)
    {
        //compare both sides' data usage record
        require(_tolerance(_range, _usageLimit));
        //pay the provider according to data usage recorded by the provider if tolerance is succeeded.
        _cashier (msg.sender, usageOf[providerOf[msg.sender]][msg.sender]);
        //clear data usage record on both sides
        usageOf[providerOf[msg.sender]][msg.sender] = 0;
        usageOf[msg.sender][providerOf[msg.sender]] = 0;
        //reasonably decrease number of users of the provider by 1
        numberOfUsers[providerOf[msg.sender]] -= 1;
        //check if the clear operation if successful
        assert(usageOf[providerOf[msg.sender]][msg.sender] == usageOf[msg.sender][providerOf[msg.sender]]);
        //return on function success 
        return true;
    }
}