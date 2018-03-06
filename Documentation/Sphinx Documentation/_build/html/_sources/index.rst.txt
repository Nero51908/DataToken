.. DataTokenAlpha documentation master file, created by
   sphinx-quickstart on Tue Mar  6 19:12:07 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to DataTokenAlpha!
===============================================

.. toctree::
   :maxdepth: 2
   :caption: Contents:

This is the documentation of DataTokenAlpha.
DatatokenAlpha is my final year project.

Introduction
============

This project aims to develop a scheme to allow peer-to-peer (P2P) cellular data sharing and to 
construct a prototype Ethereum smart contract with respect to the scheme using Solidity which is 
a blockchain oriented programming language. Smart contract DataToken-Alpha (latest version 0.2.2) 
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


Contract Variables
==================

Contracts variables are declared at the beginning of solidity contract body.
In this section, variable types and availability are indicated by source code definition 
below each mentioned variables.

owner
-----
::
    
    address owner;

tokenName
---------
::

    string public tokenName = "dataToken";

decimals
--------
::

    uint public decimals = 9;

initialSupply
-------------
::

    uint256 initialSupply = 666;

totalSupply
-----------
::

    uint256 totalSupply = initialSupply * 10 ** decimals;

role
----
::

    enum role {ISRECEIVER, ISPROVIDER, UNDERSERVICE}

balance
-------
::

    mapping (address => uint256) public balance;

identification
--------------
::

    mapping (address => role) public identification;

providerOf
----------    
::

    mapping (address => address) public providerOf;

priceOf
-------
::

    mapping (address => uint256) public priceOf;

usageOf
-------
::

    mapping (address => mapping (address => uint256)) public usageOf;

passwd
------
::

    mapping (address => string) internal passwd;

Event
=====


Internal Functions
==================

Internal functions are invisible to API and external calls from other contracts.

_transfer
---------
::

    function _transfer(address _from, address _to, uint256 _value)

A call of this function is able to transfer _value amount of token
from Ethereum address _from to address _to. The function has the 
highest authority in a transfer operation. 

It is defined as internal 
for safety concern that API (web3 implemented by ethereum core team) 
cannot call this function directly. 

This function is the core of function transfer()


_sur
----
::

    function _sur(address _user, role _oldrole, role _newrole)

sur represents switch user role. Public functions that can switch 
user roles all depend on this internal function.

_affordableData
---------------
::

    function _affordableData (address _wallet, uint256 _price)

_tolerance
----------
::

    function _tolerance (uint256 _range, uint256 _usageLimit)

_cashier
--------
::

    function _cashier (address _payer, uint256 _volume)


Public Functions
================

Public functions can be invoked in other contracts and is callable by API.
DataTokenAlpha
--------------
::

    function DataTokenAlpha() public {
        owner = msg.sender;
        balance[owner] = totalSupply;
    }

This is the constructor function of solidity contract DataTokenAlpha.

transfer
--------
::

    function transfer(address _to, uint256 _value)

buyToken
--------
::

    function buyToken()

suProvider
----------
::

    function surProvider (uint256 _price, string _passwd)

suReceiver
----------
::

    function surReceiver (uint _numberOfUsers)

link
----
::

    function link (address _provider)

usageRecord
-----------
::

    function usageRecord (address _theOtherSide, uint256 _usage) 

payAndLeave
-----------
::

    function payAndLeave (uint256 _range, uint256 _usageLimit)



