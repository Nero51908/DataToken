pragma solidity ^0.4.21;

contract DataTokenAlpha {
    /**
    *Contract property
    */
    address owner;
    //contract (token) properties
    string public tokenName = "DataToken";
    //
    string public tokenSymbol = "DAT";
    //
    uint public decimals = 9;
    //
    uint256 initialSupply = 666;// GDAT
    //the possible bigest number of coins (including non-integer valued coins)i.e. number of coins express by the smallest unit of this token
    uint256 totalSupply = initialSupply * 10 ** decimals;// DAT

    /**
    *Tunable values
    *can be changed by owner's call of correponding functions
    */
    //data usage information should be reported less than every 30 sec. This value can be changed by 
    uint256 reportPeriod = 30; // sec
    //within such time differnece, two data usage report are considered as "synchronized"
    uint256 coherenceTime = 60; // sec
    //DataToken Price
    uint256 tokenPrice = 10 ** 9;// wei/DAT
    //acceptable reported data traffic difference
    uint256 usageTolerance = 10;// MB 

    /**
    *Runtime variables
    */
    //APID counter, each new provider will be given this number. It's value updates by +1 after each give out (implemented in surProvider function).
    uint256 APID_counter = 1;
    //ethereum users can be receiver or provider. By defualt they are all receivers. by a successful call of surProvider, a user can be recognized as a provider.
    enum role {ISRECEIVER, ISPROVIDER, PAIRED}
    //spsecify payment type;
    enum forcePayType {FUSEOFPROVIDER, FUSEOFRECEIVER}
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
    mapping (address => mapping (address => uint256)) public usageOf;//latest_usage
    // count is directional. the first address submits the report and the second is the direction of it's connected address
    mapping (address => mapping (address => uint256)) public reportCount;
    // timeStamp is directional. the first address submits the report and the second is the direction of it's connected address
    mapping (address => mapping (address => uint256)) public frontTimestamp;
    // agreement that determines how many token to pay for function payAndLeave()
    // agreement has no direction, it is an agreed value of both provider and receiver
    mapping (address => mapping (address => uint256)) public agreement;//agreed usage that can be used in an invoice, agreement[provideraddress][receiveraddress]
    //provider's pocket// used in link() function
    //receiver has a 'ticket with number' and provider knows the number since a receiver connects to it
    //when a receiver try to connect the provider
    //provider with compare the number from receiver and the number corresponding to such receiver
    //if match, let the receiver in (WLAN)
    //this is using a white name list
    //this kind of login is more like nonce rather than token based authentication
    mapping (address => mapping(address => bytes32)) internal providerPocket;    
    //
    /**
    *Events
    *making log
    *easy for web3 to listen to
    */
    //transfer event infomation. value is 
    event LogTransfer(
        address _from,
        address _to,
        uint256 value
    );
    //switch user role event
    event LogSur(
        address _user,
        role _newrole,
        bool success
    );
    //provider on line
    event LogProviderArchive(
        address _provider,
        uint256 _APID,
        uint256 _price // DAT/MB
    );

    /**
    *Constructor function
    *assigns contract owner;
    *give all token balance to the owner;
    */
    constructor() 
    public
    {
        owner = msg.sender;
        balance[owner] = totalSupply;
    }

    /**
    *tuner()
    *to change tunable contract variables
    *only owner can call this function.
    */
    function tuner (uint256 _reportPeriod, uint256 _coherenceTime, uint256 _tokenPrice, uint256 _usageTolerance)
    public
    {
        require(msg.sender == owner);
        reportPeriod = _reportPeriod;
        coherenceTime = _coherenceTime;
        tokenPrice = _tokenPrice;
        usageTolerance = _usageTolerance;
        assert(tokenPrice == _tokenPrice);
        assert(reportPeriod == _reportPeriod);
        assert(coherenceTime == _coherenceTime);
        assert(usageTolerance == _usageTolerance);
    }

    /**
    * A getter function.
    * Show Ether balance of this contract (DataToken) in terms of wei
    * This balance is a result of buyToken() function
    * Other addresses buy token will pay Ether to this contract address
    * And owner address distributs token to the buyer
    * However, if the owner address call buyToken function
    * the result is equivalent to depositing an amount of Ether into the contract nothing else will happen
    */
    function contractBalance() 
    public
    constant
    returns(uint256 value)
    {
        value = address(this).balance;
        return value;
    }

    /**
    * core of transfer()
    * it manipulates tokenbalance of addresses and it is rebust to errors. 
    * (on error, revert)
    *
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
    returns(bool success)
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
        // emit event
        emit LogTransfer(_from, _to, _value);
        return true;
    }

    /**
    *function to tranfer tokens.
    * Can be called publicly
    * no requirement on caller's identification mapping value
    *
    *_to receiver of _value
    *_value value of token to transfer
    * 
    *_transfer will check whether the operation succeeded or not
    * if _transfer succeeded, transfer will return value of token that has been transfered as success message
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
    * 
    *requires input Ethereum value
    * 
    * returns amount of tokens bought as a success message
    */
    function buyToken()
    payable
    public
    {
        // msg.value is in wei, DataToken has 9 decimals, msg.value / 10 ** 9 converts wei value to DataToken value.
        _transfer(owner, msg.sender, msg.value / tokenPrice);
        // emit the fact of a successful transfer
        emit LogTransfer(owner, msg.sender, msg.value / tokenPrice);
    }

    /**
    * Safe to call directly (maybe...)
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
    returns(bool success)
    {
        // safety concern
        require(identification[_user] == _oldrole);
        // assign new identification mapping value
        identification[_user] = _newrole;
        // safety concern
        assert(identification[_user] == _newrole);
        // on success return success so that caller can trigger event log
        return true;
    }

    /**
    *public function
    *
    *a receiver is switched to be a provider after a success call of this function
    *
    *param {uint256} _price price of wifi service in terms of DataToken per 1 MB data
    *
    *@return {bool} success whether the function has finished successfully
    *@return {address} provider address of the function caller
    *
    * priceOf mapping is not changed by this function throw
    */
    function surProvider (uint256 _price)
    public
    {
        //_sur() has safety check
        if (_sur(msg.sender,role.ISRECEIVER,role.ISPROVIDER)) {
            //if _sur() succeeds, emit role switch true event
            emit LogSur(msg.sender, role.ISPROVIDER, true);
        } else {
            //if not (bool type is false by default), emit false event and function will revert
            emit LogSur(msg.sender, role.ISPROVIDER, false);
        }
        //assign price unit: DataToken per MB
        priceOf[msg.sender] = _price;
        //assign provider ID to be shown in SSID in physical layer
        if (APID[msg.sender] == 0) {
            //if APID is default, the caller has never been a provider
            //assign new provider an APID
            APID[msg.sender] = APID_counter;
            //with providerBehind[APID] user can find provider address with the APID 
            providerBehind[APID_counter] = msg.sender;
            APID_counter += 1;
        }
        // safety check, APID_counter is counting right, provider address is correct, pricing is correct
        assert(providerBehind[APID_counter - 1] == msg.sender && priceOf[msg.sender] == _price);
        // provider buil complete, emit event
        emit LogProviderArchive(msg.sender, APID_counter - 1, _price);
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
    {
        //caller has to be provider
        require(identification[msg.sender] == role.ISPROVIDER);
        //provider has to have no linked user
        //numberOfUsers only increment by 1 after a successful link() call
        //and it only decrement by 1 after a successful payAndLeave() call
        require(numberOfUsers[msg.sender] == 0);
        //_sur() will revert if no success
        if (_sur(msg.sender, role.ISPROVIDER, role.ISRECEIVER)) {
            emit LogSur(msg.sender, role.ISRECEIVER, true);
        } else {
            emit LogSur(msg.sender, role.ISRECEIVER, false);
        }
    }

    /**
    * Calculate max volume can be payed by function caller
    * internally defined estimation function
    */
    function _affordableData (address _wallet)
    internal
    view
    returns (uint256 maxVolume)
    {
        //estimated max data usage in MB
        return balance[_wallet] / priceOf[providerOf[_wallet]];
    }

    /**
    *
    *public function that links message sender to the chosen provider
    * _providerID:= input APID of the provider which is available to physical frontend receiver
    * _yourkey:= input a key that you want to use to make a stamp on the real key you put in provider's pocket
    *
    *message sender must be receiver
    *
    *providerBehind[_providerID] is the address of provider
    *
    *(Suppose user interface can translate SSID to be address of provider and use that address as argument)
    *
    *affordable data is estimated in this function and the estimation is required to be larger than 1 (MB)
    *
    *role of message sender is changed to be PAIRED which means can call no function but payandleave()
    *
    *return messagesender address and estimation of it's max possible data usage
    *
    *when provider address is not assigned to message sender successfully, throw.
    *
    *when message sender role is not changed to be role.PAIRED, throw.
    * 
    * *************************potential issue*********************************
    * There is possibility that the receiver drops the physical link between it and the provider
    * In that case, the receiver has called link() once and pass through doorkeeper() once
    * role.PAIRER can't call link() and No password to knock doorkeeper() again
    * In current version, the user must call payAndLeave() to reset it's identification as role.ISRECEIVER
    * 
    */
    function link (uint256 _providerID, uint256 _yourkey)
    public
    returns(bytes32 pwd)
    {
        // target identification check; caller identification is checked in _sur() call
        require(identification[providerBehind[_providerID]] == role.ISPROVIDER);
        //balance check, more than 20 MB affordable data volume is required. (currently no reason for the min affordable threshold)
        require(_affordableData(msg.sender) >= 20);
        //change receiver identity to PAIRED
        if (_sur(msg.sender, role.ISPROVIDER, role.PAIRED)) {
            //if _sur() success
            emit LogSur(msg.sender, role.PAIRED, true);
            //assign the provider address to receiver's mapping to establish the link
            providerOf[msg.sender] = providerBehind[_providerID];
            //add one use count to provider
            numberOfUsers[providerBehind[_providerID]] += 1;  
            //put a key in provider's pocket for frontend handshake, _yourkey is to shift block.timestamp, maybe there are some better ways
            providerPocket[providerBehind[_providerID]][msg.sender] = keccak256(block.timestamp + _yourkey);
            // safety: caller has been correctly linked to provider address, caller role.PAIRED is guaranteed by _sur()
            assert(providerOf[msg.sender] == providerBehind[_providerID]);
            // pwd is the same as providerPocket[providerBehind[_providerID]][msg.sender] 
            // doorKeeper() will check this value when providers frontend detects connection request (when doorKeeper() is called) 
            return providerPocket[providerBehind[_providerID]][msg.sender];
        } else {
            emit LogSur(msg.sender, role.PAIRED, false);
        }
    }

    /**
    doorkeeper for providers
    _knocker is whichever address delivered by front end as provider to backend doorkeeper function
    _pwd is the bytes32 type number input from provider's front end where the physical knocker show this value to the provider's front end
     */
    function doorKeeper (address _knocker, bytes32 _pwd)
    public
    returns(bool letIn)
    {
        //prerequiest
        require(identification[msg.sender] == role.ISPROVIDER && identification[_knocker] == role.PAIRED);
        //guarentee the knocker is connected to some address (it has called link function) without knowing whether the provider is msg.sender
        
        //retreive the nonce like one-time key put link() as a result of the receiver's call
        letIn = providerPocket[msg.sender][_knocker] == _pwd;
        //reset mapping value. this one-time password (token) is used and expired after this function
        //i.e. once any one try to connect the provider with the identity of the paired receiver
        //and the provider front checked with the contract via this only function
        //the password set by the paired receiver will be expired no matter the _knocker has provided the correct password or not.
        //to hijack a paired receiver address, the malicious user must send   
        delete providerPocket[msg.sender][_knocker];
        return letIn;
    }

    /**
    *core to record data usage
    *
    *Designed to be called frequently by fontend of both sides to update data traffic volume 
    *
    *param _volRecord data usage 
    *data usage is in terms of MB
    */
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// To handle forced payment caused by excedding affordable usage (not implemented yet) or 
// possibly dishonest behavior (implemented, waiting for test) and too much time gap between two reports of the same count (implemented, waiting for test)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
    /**
    *core of a forced payment because the detection of unstable or possibly dishonest link
    *tell it who is gonna pay
    *and
    *pay with respect to which ledger (provider's ledger or user's)
    *there are two types of forcePayTypes: FUSEOFPROVIDER (use the latest usage record in receiver's ledger), FUSEOFRECEIVER (use provider's ledger) 
    *_type input of this function can only be ether forcePayType.FUSEOFPRIVIDER or forcePayType.FUSEOFRECEIVER
    */
    function _cashier (uint256 _usage, uint256 _price)
    internal
    pure
    returns (uint256 bill)
    {
        return _usage*_price;
    }

    function _forceInvoice(address _user, forcePayType _type)
    internal
    {
        require(identification[_user] == role.PAIRED);
        //
        //if _transfer() succeeds, emit the event
        if (_type == forcePayType.FUSEOFPROVIDER) {
            //pay as receiver's record by calling this NOTE that the _user is always the receiver (PAIRED)
            _transfer(_user,providerOf[_user], _cashier(usageOf[_user][providerOf[_user]],priceOf[providerOf[_user]]));
        } else { //_type == forcePayType.FUSEOFRECEIVER
            //pay as provider's record by calling this NOTE that the _user is always the receiver (PAIRED)
            _transfer(_user,providerOf[_user], _cashier(usageOf[providerOf[_user]][_user],priceOf[providerOf[_user]]));
        }
    }
    

    /**fuse
    *fuse can be called by provider or receiver
    *log latest data usage 
    *check whether the link is still valid
    *if the link is no longer valid, force the _user pay the bill and break the link like fuse burnt
    *_timestamp is the timestamp of the report provided by frontend
    *no longer valid conditions are:
    *difference between timestamps of two usageOf of the same count is larger than coherenceTime (contract state variable)
    *timestamps satisfies coherenceTime, but the two usage values do not agree even with a tolerance usageTolerance (contract state variable)
    *too long waiting for a match (need to detect time..but how....)
    *
    */
    // for providers to call 
    function fuse (address _user, uint256 _usage, uint256 _timestamp)
    public
    returns (bool fuseBurn)
    {
        // fuse called by provider once and by linked user onece is called one "match".
        // require:  caller is provider,                          _user is linked to caller,          usage report never decrease,                count must wait for it's match
        require(identification[msg.sender] == role.ISPROVIDER && msg.sender == providerOf[_user] && _usage >= usageOf[msg.sender][_user] && reportCount[msg.sender][_user] <= reportCount[_user][msg.sender]);
        // if fuse burns, which is caused by new datausage report from provider
        // new usage log
        usageOf[msg.sender][_user] = _usage;
        reportCount[msg.sender][_user] += 1;
        frontTimestamp[msg.sender][_user] = _timestamp;
        // check with validity:
        // conditions to burn the fuse
        // usage decreases (burn instantly) => issue a forced invoice to let the user pay as the latest valid usage, or
        if (reportCount[_user][msg.sender] == reportCount[msg.sender][_user]) {
            // try to make an agreement
            //
            // time coherence detection
                // note: this condition is triggered because provider reports later than user
            if (_timestamp - frontTimestamp[_user][msg.sender]>coherenceTime) {
                // difference between timestamps of two usageOf of the same count is larger than coherenceTime (contract state variable)
                _forceInvoice(_user,forcePayType.FUSEOFPROVIDER);
                return true;
            } else {
                if ((usageOf[msg.sender][_user]-usageOf[_user][msg.sender])>usageTolerance || (usageOf[_user][msg.sender]-usageOf[msg.sender][_user])>usageTolerance) {
                    //timestamps satisfies coherenceTime, but the two usage values do not agree even with a tolerance usageTolerance (contract state variable)
                    _forceInvoice(_user,forcePayType.FUSEOFPROVIDER);
                    return true;
                } else { // consistent reports received assign agreement value by there mean value
                    agreement[msg.sender][_user] = (usageOf[_user][msg.sender] + usageOf[msg.sender][_user]) / 2;
                    return false;
                }
            }
        } 
    }
    // for paired uses to call
    function fuse (uint256 _usage, uint256 _timestamp)
    public
    returns (bool fuseBurn)
    {     
        // requires: caller is paired user (no need to input provider), usage report will never decrease,             wait for a match if this report count is curretly leading
        require(identification[msg.sender] == role.PAIRED && _usage >= usageOf[msg.sender][providerOf[msg.sender]] && reportCount[msg.sender][providerOf[msg.sender]] <= reportCount[providerOf[msg.sender]][msg.sender]);
        // new usage log
        usageOf[msg.sender][providerOf[msg.sender]] = _usage;
        reportCount[msg.sender][providerOf[msg.sender]] += 1;
        frontTimestamp[msg.sender][providerOf[msg.sender]] =  _timestamp;
        // trying to make an agreement
        if (reportCount[msg.sender][providerOf[msg.sender]] == reportCount[providerOf[msg.sender]][msg.sender]) {
            if ((_timestamp - frontTimestamp[providerOf[msg.sender]][msg.sender])>coherenceTime) {
                _forceInvoice(msg.sender,forcePayType.FUSEOFRECEIVER);
                return true;
            } else {
                if ((usageOf[msg.sender][providerOf[msg.sender]]-usageOf[providerOf[msg.sender]][msg.sender])>usageTolerance || (usageOf[providerOf[msg.sender]][msg.sender]-usageOf[msg.sender][providerOf[msg.sender]])>usageTolerance) {
                    _forceInvoice(msg.sender,forcePayType.FUSEOFRECEIVER);
                    return true;
                } else { // consistent reports received assign agreement value by there mean value
                    agreement[providerOf[msg.sender]][msg.sender] = (usageOf[msg.sender][providerOf[msg.sender]] + usageOf[providerOf[msg.sender]][msg.sender]) / 2;
                    return false;
                }
            }       
        }   
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    *normal case used data < datalimit (fuse functions will help to watch the data limit)
    *payAndLeave function. 
    *
    *assume that tolerance of data usage error obtained by comparing both records is always satisfied (otherwise this function will never succeed)
    *
    * _range is the range of tolerance
    * _usageLimit could be removed in the next version, it is not necessary to be a input, a mapping can replace it
    * 
    * on payment success, this function will return value of token that msg.sender has paid.
    */
    function payAndLeave ()
    public
    {
        // caller must be a paired user
        require(identification[msg.sender]==role.PAIRED);
        transfer(providerOf[msg.sender],agreement[providerOf[msg.sender]][msg.sender]*priceOf[providerOf[msg.sender]]);
        //reasonably decrease number of users of the provider by 1        
        numberOfUsers[providerOf[msg.sender]] -= 1;
        //safety check number of users under a provider is never smaller than 0
        assert(numberOfUsers[providerOf[msg.sender]] >= 0);
        //clear data usage record on both provider's and receiver's sides
        delete usageOf[providerOf[msg.sender]][msg.sender];
        delete usageOf[msg.sender][providerOf[msg.sender]];
    }
}