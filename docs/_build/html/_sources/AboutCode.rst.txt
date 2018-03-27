Contract Variables
==================

.. note::

    Contracts variables are declared at the beginning of solidity contract body.
    In this section, variable types and availability are indicated by source code definition 
    below each mentioned variables.


owner
-----
.. code-block:: javascript
    
    address owner;

The message sender address of the transaction that has initiated this 
DataTokenAlpha contract is stored in this variable.

All initial supply tokens are assigned to this address.
That is, all usable tokens are sold buy owner address.

tokenName
---------
.. code-block:: javascript
 
    
    string public tokenName = "dataToken";

The name of token defined by this contract is dataToken.

decimals
--------
.. code-block:: javascript

    uint public decimals = 9;

This token will support 9 digits after decimal point.
The number of 9 actually defines the smallest operable unit of each token.

initialSupply
-------------
.. code-block:: javascript

    uint256 initialSupply = 666;

There will be 666 usable tokens in this contract.

totalSupply
-----------
.. code-block:: javascript

    uint256 totalSupply = initialSupply * 10 ** decimals;

Number of tokens in terms of the smallest unit 
is 666,000,000,000.

.. note::
    The smallest unit is DataToken. There are 666,000,000,000 DataTokens supplied by this contract.

role
----
.. code-block:: javascript

    enum role {ISRECEIVER, ISPROVIDER, PAIRED}

This variable defines three possible roles of contract users.

Numerically, identification has values:

* role.ISRECEIVER = 0
* role.ISPROVIDER = 1
* role.PAIRED = 2

.. note::
    The following variables are of mapping type. 
    
    `Click to find mapping in solidity documentation <http://solidity.readthedocs.io/en/develop/types.html?#mappings>`_

identification
--------------
.. code-block:: javascript

    mapping (address => role) public identification;

This mapping takes Ethereum address as key and role (enum type) as the mapped value.

By default, any unassigned value is recognized as 0, therefore, 
Ethereum addresses automatically have *role.ISRECEIVER* (numerical value is 0) as mapping values of `identification`_.

When a receiver address calls function `surProvider`_,
*identification* mapping value of this address will be changed to *role.ISPROVIDER* (numerical value is 1).

When a receiver address has called function :ref:`link` successfully, 
mapping value of the address will be designated as *role.PAIRED* (numerical value is 2).

APID
----
.. code-block:: javascript

    mapping (address => uint256) public APID;

This mapping shows numerical ID of a provider address.

When a provider is deploying Wi-Fi AP, frontend client could 
query value of this mapping with the Ethereum address 
of the provider. Then the unique numerical ID can be shown in SSID.

There are two reasons for this mapping:

* SSID has String length limit. A full length Ethereum address exceeds such limitation, however, a truncated address is not easy to resolve.

* Ethereum address behind a wireless AP could be protected by this APID. Currently, `providerBehind`_ is publicly declared, but it's high availability is not necessary. 

APID_counter
------------
.. code-block:: javascript

    uint256 APID_counter = 1;

This number will be assigned to a newly registered provider.

If a successful call of `surProvider`_ is initiated by 
a user without :ref:`APID' value,
APID_counter will be assigned to the new provider's `APID` mapping,
and the value of APID_counter will be updated by +1 as `surProvider`_ implemented.

balance
-------
.. code-block:: javascript

    mapping (address => uint256) public balance;

Mapping balance uses Ethereum address as key and number of tokens as value.

Token balance of each contract user can be viewed by calling this mapping.

Only one internal function :ref:`_transfer` can manipulate values of this mapping without restriction.

providerBehind
--------------
.. code-block:: javascript

    mapping (uint256 => address) public providerBehind;

This mapping is a conversed version of `APID`_ mapping.

APID of an account is a key of this mapping.
The value corresponds to the key (APID grabbed from SSID) 
is the Ethereum address of the AP host.

numberOfUsers
-------------
.. code-block:: javascript

    mapping (address => uint) public numberOfUsers;

For each contract user of provider role, this mapping is important.

* When a receiver is linked to a provider by :ref:`link` function, mapping value of the provider should be added by 1.

* When the receiver has successfully called function `payAndLeave`_, the value of numberOfUsers should be decreased by 1.

* Only when this mapping value is 0 which is the default value, can a provider call function `surReceiver`_ to switch user role back to *role.ISRECEIVER*.

providerOf
----------    
.. code-block:: javascript

    mapping (address => address) public providerOf;

For each user of *role.PAIRED* who was of *role.ISRECEIVER* before a successful call of :ref:`link` function,
this mapping will be assigned by the Ethereum address of the linked provider.

Only users being served has nonzero providerOf mapping.
Value of this mapping will be reset to 0 after a successful call of `payAndLeave`_.

priceOf
-------
.. code-block:: javascript

    mapping (address => uint256) public priceOf;

When a receiver intends to switch user role to be a provider, 
function `surProvider`_ will request a input that specifies pricing of this AP service to deploy in DataToken/MB.

usageOf
-------
.. code-block:: javascript

    mapping (address => mapping (address => uint256)) public usageOf;

This is a mapping designed to verify data usage information to prevent cheating on both sides when issuing payment.

A function `_tolerance`_ is defined to check whether data usage record can reach a consensus.

If records from both provider and receiver agree with each other, the receiver will pay for the amount of data usage specified by the provider.

.. warning::
    What will happen if a consensus is not reached has not been defined yet!

passwd
------
.. code-block:: javascript

    mapping (address => string) internal passwd;

This mapping is where provider can store their designated key to generate dynamic PIN for wireless AP authentication.

User will be require to input a password when function `surProvider`_ is called.

.. This distinguishes Chapers
.. This distinguishes Chapers
.. This distinguishes Chapers

Internal Functions
==================

.. note::

    Internal functions are invisible to Web3 Javascript API and external calls from other contracts.

.. warning::

    Internal functions are defined with great power that can easily change data on Ethereum like DataToken balance of contract users. 

_transfer
---------
.. code-block:: javascript

    function _transfer(address _from, address _to, uint256 _value)

.. warning::

    This function has great power that it can manipulate balance between addresses without any restriction.
    
A call of this function is able to transfer _value amount of token
from Ethereum address _from to address _to. The function has the 
highest authority in a transfer operation. 

It is defined as internal 
for safety concern that API (web3 implemented by ethereum core team) 
cannot call this function directly. 

.. tip::

    This function is the core of functions that are able to cause change of DataToken balance.

_sur
----
.. code-block:: javascript

    function _sur(address _user, role _oldrole, role _newrole)

"sur" represents switch user role. This function will not check current user role but will
simply alter `identification`_ mapping of input *_user* address with input *_newrole*.
Public functions that can switch user roles all depend on this internal function.

.. tip::

    This function is the core of function `surReceiver`_ and function `surProvider`_.

_affordableData
---------------
.. code-block:: javascript

    function _affordableData (address _wallet, uint256 _price)

This function is used to find data usage limitation for a receiver.

DataToken balance of this receiver and data service pricing of the linked provider are considered.

The output value can be used for data usage countdown.

.. warning::

    Current version of contract is not ready for the countdown feature.

.. tip::

    function `link`_ depends on this function because it requires receiver must have balance to pay for no less than 1 MB to call function `link`_.

_tolerance
----------
.. code-block:: javascript

    function _tolerance (uint256 _range, uint256 _usageLimit)

This function is used from receiver's perspective. When a receiver is about to quit AP service from the provider,
this function checks mapping `usageOf`_ values of both the receiver and the provider to make sure they agree with each other within a tolerance defined as consensus of this contract.

.. tip::

    function `payAndLeave`_ requires _tolerance to be true.

_cashier
--------
.. code-block:: javascript

    function _cashier (address _payer, uint256 _volume)

This function is responsible to collecting payment from a receiver when the receiver calls function `payAndLeave`_.

.. tip::

    This function is an important component in function `payAndLeave`_.


.. This distinguishes Chapers
.. This distinguishes Chapers
.. This distinguishes Chapers

Public Functions
================

Public functions can be invoked in other contracts and is callable by Web3 Javascript API.

DataTokenAlpha
--------------
.. code-block:: javascript
    :linenos:

    function DataTokenAlpha() public {
        owner = msg.sender;
        balance[owner] = totalSupply;
    }

.. tip::

    This is the constructor function of solidity contract DataTokenAlpha.

transfer
--------
.. code-block:: javascript

    function transfer(address _to, uint256 _value)

buyToken
--------
.. code-block:: javascript
    :linenos:

    function buyToken()
    payable
    public
    returns(bool success)
    {
        _transfer(owner, msg.sender, msg.value / 10 ** 9);
        return true;
    }

This function is payable. That means, any contract user can call this function with a specified Ethereum value in terms of `wei <http://ethdocs.org/en/latest/ether.html>`_.
The function will then transfer equivalent amount of DataToken from *owner* address to the buyer's address according to
the exchange rule that 1 DataToken = 1,000,000,000 wei = 1 Gwei.

.. warning::
    
    Thi function will only transfer Ether from buyer to contract rather than from buyer to *owner* to buy DataToken. There should be a way for the *owner* to deposit Ether from the contract.

surProvider
----------- 
.. code-block:: javascript

    function surProvider (uint256 _price, string _passwd)

This function can only be called by contract users with `identification`_ role.ISRECEIVER.
On success, *role.ISPROVIDER* will be assigned to identification mapping of the message sender.

surReceiver
-----------
.. code-block:: javascript

    function surReceiver (uint _numberOfUsers)

When a provider want to switch back to be a receiver, this function will be there for help.
The provider will be required to have no linked receiver who is using wireless AP under the name of this provider.
On success, *role.ISRECEIVER* will be assigned to `identification`_ mapping of the message sender.

link
----
.. code-block:: javascript

    function link (address _provider)

Only receivers with *role.ISRECEIVER* can call this function.
This function will pair the message sender with the designated provider.

..warning::

    This function actually relies on a address resolver since the frontend client should only feed the function APID. And such resolver is not implemented.
    
usageRecord
-----------
.. code-block:: javascript

    function usageRecord (address _theOtherSide, uint256 _usage) 

This function assigns value of `usageOf`_ in terms of MB.

.. warning::

    There should be some timing and data refreshing features to make the mapped data up to date, however, this feature is not implemented within this version of contract.
     
payAndLeave
-----------
.. code-block:: javascript

    function payAndLeave (uint256 _range, uint256 _usageLimit)

When a receiver wish to leave it's wireless AP, it can call this function to issue a payment and disconnect from the provider.

Event
=====

.. note::
    Event is used as log when important information of the contract is changed, for example, user balance changed as a result of transfer.
    
Transfer
--------
.. code-block:: javascript

    event Transfer(address _from, address _to, uint256 value);

Adding this event to the end of a function that issues token transfers will trigger a return message about the transfer. 

sur
---
.. code-block:: javascript

    event Sur(address _user, role _newrole, bool success);

When a user switch user role, this event will return a message indicating the original user role, the intended user role and whether the operation has succeeded.
