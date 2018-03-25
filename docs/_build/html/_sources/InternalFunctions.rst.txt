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
