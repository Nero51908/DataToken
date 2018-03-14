.. DataTokenAlpha documentation master file, created by
   sphinx-quickstart on Tue Mar  6 19:12:07 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to DataTokenAlpha!
==========================

.. toctree.. code-block:: javascript
   :maxdepth: 2
   :caption: Contents:

This is the documentation of DataTokenAlpha.
DatatokenAlpha is my final year project.

.. image:: logo.png
    :scale: 50 %
    :alt: alternate text
    :align: center


Introduction
============

This project aims to develop a scheme for peer-to-peer (P2P) cellular data sharing and to 
construct a prototype Ethereum smart contract with respect to the scheme using Solidity which is 
a blockchain oriented programming language. Smart contract DataToken-Alpha (latest version 0.3.2) 
as the scheme implementation has been under development. Hence, DataToken, a token of Ether 
(Intrinsic Cryptocurrency of Ethereum) is created for data service transfer recording.The uniqueness 
of such implementation is that all the information held by the contract is protected by Ethereum 
network based on blockchain technology from computational hacking.

The implementation is started from analyzing behaviors that a ledger system is expected to have. 
By design, the contract is firstly able to offer and manage token like a bank in real world 
and secondly, it is capable to work as a cellular data service trade centre where users of such 
contract are able to transfer Internet access in terms of cellular data usage and token. 
Solidity code thud is used to implement necessary features with respect to the behaviors mentioned above. 
Finally, a prototype of DataToken-Alpha for autonomous data trading is ready for further polish 
in the next semester when this project will focus on upgrading DataToken-Alpha to be a practically 
deployable smart contract as close as possible.




Coding Style
============
Camel case names for variable and function names.
Internal functions all start with an underscore _.
Input parameter of functions starts with an underscore _.


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

APID_counter
------------
.. code-block:: javascript

    uint256 APID_counter = 1;

This number will be assigned to a newly registered provider.

If a successful call of `surProvider`_ is initiated by 
a user without `APID`_ value,
APID_counter will be assigned to the new provider's `APID`_ mapping,
and the value of APID_counter will be updated by +1 as `surProvider`_ implemented.



role
----
.. code-block:: javascript

    enum role {ISRECEIVER, ISPROVIDER, UNDERSERVICE}

This variable defines three possible roles of contract users.

Numerically, identification has values:

* role.ISRECEIVER = 0
* role.ISPROVIDER = 1
* role.UNDERSERVICE = 2

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

When a receiver address has called function `link`_ successfully, 
mapping value of the address will be designated as *role.UNDERSERVICE* (numerical value is 2).

APID
====
.. code-block:: javascript

    mapping (address => uint256) public APID;

This mapping shows numerical ID of a provider address.

When a provider is deploying Wi-Fi AP, frontend client could 
query value of this mapping with the Ethereum address 
of the provider. Then the unique numerical ID can be shown in SSID.

There are two reasons for this mapping:

* SSID has String length limit. A full length Ethereum address exceeds such limitation, however, a truncated address is not easy to resolve.

* Ethereum address behind a wireless AP could be protected by this APID. Currently, `providerBehind`_ is publicly declared, but it's high availability is not necessary. 

balance
-------
.. code-block:: javascript

    mapping (address => uint256) public balance;

Mapping balance uses Ethereum address as key and number of tokens as value.

Token balance of each contract user can be viewed by calling this mapping.

Only one internal function `_transfer`_ can manipulate values of this mapping without restriction.

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

* When a receiver is linked to a provider by `link`_ function, mapping value of the provider should be added by 1.

* When the receiver has successfully called function `payAndLeave`_, the value of numberOfUsers should be decreased by 1.

* Only when this mapping value is 0 which is the default value, can a provider call function `surReceiver`_ to switch user role back to *role.ISRECEIVER*.

providerOf
----------    
.. code-block:: javascript

    mapping (address => address) public providerOf;

For each user of *role.UNDERSERVICE* who was of *role.ISRECEIVER* before a successful call of `link`_ function,
this mapping will be assigned by the Ethereum address of the linked provider.

Only users under services has nonzero providerOf mapping.
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

Internal Functions
==================

.. note::

    Internal functions are invisible to Web3 Javascript API and external calls from other contracts.

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

This function is the core of function transfer()


_sur
----
.. code-block:: javascript

    function _sur(address _user, role _oldrole, role _newrole)

sur represents switch user role. Public functions that can switch 
user roles all depend on this internal function.

_affordableData
---------------
.. code-block:: javascript

    function _affordableData (address _wallet, uint256 _price)

_tolerance
----------
.. code-block:: javascript

    function _tolerance (uint256 _range, uint256 _usageLimit)

_cashier
--------
.. code-block:: javascript

    function _cashier (address _payer, uint256 _volume)


Public Functions
================

Public functions can be invoked in other contracts and is callable by API.

DataTokenAlpha
--------------
.. code-block:: javascript
    :linenos:

    function DataTokenAlpha() public {
        owner = msg.sender;
        balance[owner] = totalSupply;
    }

This is the constructor function of solidity contract DataTokenAlpha.

transfer
--------
.. code-block:: javascript

    function transfer(address _to, uint256 _value)

buyToken
--------
.. code-block:: javascript

    function buyToken()

surProvider
----------- 
.. code-block:: javascript

    function surProvider (uint256 _price, string _passwd)

surReceiver
-----------
.. code-block:: javascript

    function surReceiver (uint _numberOfUsers)

link
----
.. code-block:: javascript

    function link (address _provider)

usageRecord
-----------
.. code-block:: javascript

    function usageRecord (address _theOtherSide, uint256 _usage) 

payAndLeave
-----------
.. code-block:: javascript

    function payAndLeave (uint256 _range, uint256 _usageLimit)



