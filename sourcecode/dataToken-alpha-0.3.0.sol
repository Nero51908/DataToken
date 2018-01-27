pragma solidity ^0.4.18;

contract dataTokenAlpha {
address owner;
//contract (token) properties
string public tokenName = "dataToken";
//
uint public decimals = 9;
uint256 initialSupply = 666;
//the possible bigest number of coins (including non-integer valued coins)i.e. number of coins express by the smallest unit of this token
uint256 totalSupply = initialSupply * 10 ** decimals;
//ethereum users can be receiver or provider. By defualt they are all receivers. by a successful call of surProvider, a user can be recognized as a provider.
enum role {ISRECEIVER, ISPROVIDER, UNDERSERVICE}
//token balance of each ethereum account. counted in totalSupply
mapping (address => uint256) public balance;
//role of an account, by default is role.ISRECEIVER
mapping (address => role) public identification;
//find a provider by ssid it uses to share data service
mapping (string => address) providerBehind;
//pricing: value per MB
mapping (string => uint256) priceOf;
//transfer event infomation. value is 
event Transfer(address _from, address _to, uint256 value);
//switch user role event
event Sur(address _user, role _newrole, bool success);
/**
*Constructor function
*
*contract has defaultly a provider for convenience of test
*/
function dataTokenAlpha() public {
    owner = msg.sender;
    balance[owner] = totalSupply;
    identification[0xdd870fa1b7c4700f2bd7f44238821c26f7392148] = role.ISPROVIDER;
    providerBehind["DataTarbitrary"] = 0xdd870fa1b7c4700f2bd7f44238821c26f7392148;
    //1 totalSupply per MB
    priceOf["DataTarbitrary"] = 1;
}

/**
*internally defined transfer operation
*/
function _transfer(address _from, address _to, uint256 _value)
internal
{
    //transfer to 0x0 means destroy such amount of token.
require(_to != 0x0);
//check if the sender has enough token
require(balance[_from] >= _value);
//check if balance of the recipient overflows (don't want overflow)
require(balance[_to] + _value > balance[_to]);
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
*/
function transfer(address _to, uint256 _value)
public
{
    _transfer(msg.sender, _to, _value);
}

/**
*internally defined switch user role function
*@param _oldrole expected current role of message sender
*@param _newrole targeted new role after a success call of this function
*/
function _sur(address _user, role _oldrole, role _newrole)
internal
{
    if (identification[_user] == _oldrole) {
        identification[_user] = _newrole;
        if (identification[_user] == _newrole) {
            Sur(_user, _newrole, true);
        } else {
            Sur(_user, _newrole, false);
        }
    } else {
        Sur(_user, _newrole, false);
    }
}

/**
*switch to provider
*/
function surProvider ()
public
{
    _sur(msg.sender,role.ISRECEIVER,role.ISPROVIDER);
}
/**
*switch to receiver
*/
function surReceiver ()
public
{
    _sur(msg.sender, role.ISPROVIDER,role.ISRECEIVER);
}

/**
*link receiver to a provider
*/
//verify a ssid sent from front and tell the front whether there is a provider behind such ssid
//estimate balance of receiver => affordable data and tell front end ot set a counter
//when front end tell data limit is acheived, stop the service

/**
*internally defined estimation function
*/
function _affordableData (address _wallet, uint256 _price)
internal
returns (uint256 _volume)
{
    return balance[_wallet] / _price;
}

//suspebd receiver (message sender)
//_sur(role.ISRECEIVER, role.UNDERSERVICE);

/**
*internally defined fee collector
*/
function _cashier (address _receiver, string _atSSID, uint256 _volume)
internal
returns (bool success)
{
    //_sur underservice back to receiver
    _transfer(_receiver, providerBehind[_atSSID], _volume * priceOf[_atSSID]);
    _sur(msg.sender, role.UNDERSERVICE, role.ISRECEIVER);
    assert(identification[_receiver] == role.ISRECEIVER);
    return true;
}

/**
*normal case used data < datalimit
*pay function
*/
function pay (string _atSSID, uint256 _volume)
public
{
    _cashier (msg.sender, _atSSID, _volume);
}

/**
*token seller function
*/
function buyToken()
payable
public
returns(bool success)
{
    _transfer(owner, msg.sender, msg.value / 10 ** 9);
    return true;
}
}