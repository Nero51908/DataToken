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
