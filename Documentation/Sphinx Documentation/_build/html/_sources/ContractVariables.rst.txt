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

When a receiver address has called function `link`_ successfully, 
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

For each user of *role.PAIRED* who was of *role.ISRECEIVER* before a successful call of `link`_ function,
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
