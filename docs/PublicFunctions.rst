################
Public Functions
################

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
