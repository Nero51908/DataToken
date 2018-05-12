Contract Variables
==================
Contracts variables are declared at the beginning of solidity contract body.
In this section, variable types and availability are indicated by source code definition 
below each mentioned variables.

owner
-----
.. code-block:: javascript

    address owner;

Owner of the contract. It is the Ethereum address which is 
the message sender of the transaction that has successfully deployed 
DataTokenAlpha contract on Ethereum network.
Total supply (666,000,000,000 tokens) is assigned to this address initially.
That is, all usable tokens of this contract in Ethereum network are sold by this owner address.

tokenName
---------
.. code-block:: javascript

    string public tokenName = "DataToken";

The name of token defined by this contract.
In current version, the contract is named "DataToken".

totalSupply
-----------
.. code-block:: javascript

    uint256 public totalSupply = 666 * 10 ** 9;

Total number of tokens is 666,000,000,000. Amount of Tokens only have discrete integer values.

reportPeriod
------------
.. code-block:: javascript

    uint256 public reportPeriod = 30; // sec

Data usage information should be reported from frontend software 
less than every 30 sec. This value can be changed by function tuner()

coherenceTime
-------------
.. code-block:: javascript

    uint256 public coherenceTime = 60; // sec

Within such time difference, two data usage report are considered as "synchronized".

tokenPrice
----------
.. code-block:: javascript

    uint256 public tokenPrice = 10 ** 9;// wei/DAT

Price in wei to purchase each DataToken from the owner.

usageTolerance
--------------
.. code-block:: javascript

    uint256 public usageTolerance = 10;// MB 

Maximum allowed difference between frontend reported data usage 
from the service provider and the receiver.

APID_counter
------------
.. code-block:: javascript

    uint256 public APID_counter = 1;

For the first time that an address choose to be a provider, 
this number is assigned to the address as the only ID of this 
address in physical layer where the numerical ID is embedded in 
SSID of the provder's Wi-Fi AP.  

.. note::
    The following variables are of enum type. 

role
----
.. code-block:: javascript

    enum role {ISRECEIVER, ISPROVIDER, PAIRED}

This variable defines three possible roles of contract users.
Numerically, identification has values:

* role.ISRECEIVER = 0
* role.ISPROVIDER = 1
* role.PAIRED = 2

forcePayType
------------
.. code-block:: javascript

    enum forcePayType {FUSEOFPROVIDER, FUSEOFRECEIVER}

This variable is a flag to show whether a invoice is triggered by fuse conditions
or initiated by the receiver's call of function payAndLeave().

Numerically, forcePayType has values:
* forcePayType.FUSEOFPROVIDER = 0
* forcePayType.FUSEOFRECEIVER = 1 

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

When a receiver address calls function :ref:`surProvider`,
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

If a successful call of :ref:`surProvider` is initiated by 
a user without :ref:`APID' value,
APID_counter will be assigned to the new provider's `APID` mapping,
and the value of APID_counter will be updated by +1 as :ref:`surProvider` implemented.

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
function :ref:`surProvider` will request a input that specifies pricing of this AP service to deploy in DataToken/MB.

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

User will be require to input a password when function :ref:`surProvider` is called.
