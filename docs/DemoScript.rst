Demonstration Script
====================

0. Initialization: Contract Deployment and Demonstration of surProvider()
------------------------------------------------------------------------
**Deploy contract as 0xca35b7d915458ef540ade6068dfe2f44e8fa733c**

Owner of the contract: **0xca35b7d915458ef540ade6068dfe2f44e8fa733c**

Token Balance of the owner: **666,000,000,000**

+---------+------------------------------------------+-------+------------------+
|provider:|0xca35b7d915458ef540ade6068dfe2f44e8fa733c|APID: 1|Price 100 (DAT/MB)|
+---------+------------------------------------------+-------+------------------+
|provider:|0x14723a09acff6d2a60dcdf7aa4aff308fddc160c|APID: 2|Price 100 (DAT/MB)|
+---------+------------------------------------------+-------+------------------+
|provider:|0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db|APID: 3|Price 300 (DAT/MB)|
+---------+------------------------------------------+-------+------------------+

1. Information Query Demonstration:
-----------------------------------
- Check **APID** of the three providers

- Check **provider address** behind APID using just APID input

- Check service **pricing** of each provider using address input

2. Demonstration of surReceiver()
--------------------------------
**Call surReceiver() function as**
    provider::

     0xca35b7d915458ef540ade6068dfe2f44e8fa733c

**user state update**
    receiver::
    
     0xca35b7d915458ef540ade6068dfe2f44e8fa733c
    
    All information about 0xca35b7d915458ef540ade6068dfe2f44e8fa733c as a
    provider is kept intact.

**Only user role is changed.**

.. tip::

    Table of user role: (meanings of values of variable identification)

    +---------------+-----------+--------------------------------------+
    |role.ISRECEIVER|numerical 0|All users are receivers by default    |
    +---------------+-----------+--------------------------------------+
    |role.PAIRED    |numerical 2|Such receiver has linked to a provider|
    +---------------+-----------+--------------------------------------+
    |role.ISPROVIDER|numerical 1|This is a user who provides service   |
    +---------------+-----------+--------------------------------------+     

3. Demonstration of link()
--------------------------
    **Call link() as**
    receiver::

     0xca35b7d915458ef540ade6068dfe2f44e8fa733c

    to try to link provider of APID: 2

    **input a hexadecimal number as password seed( a PIN)**::
    
     **e.g.** frontend input string "seed" for password generation
     can be converted to hexadecimal: 0x73656564 as input of link() function.

    .. tip::

        **put this into the input box of link() function**::
     
         2,0x73656564

    
    **Show the returned password from link() function in transaction monitor**

4. Demonstration of doorKeeper()
--------------------------------
**Call doorKeeper() as**
    provider::

     0x14723a09acff6d2a60dcdf7aa4aff308fddc160c

    Input knocker as receiver::

     0xca35b7d915458ef540ade6068dfe2f44e8fa733c

    Input password as what has been returned from link()

    ..  tip::

        Input format for instance::

         0xca35b7d915458ef540ade6068dfe2f44e8fa733c,"0x73656564"

**doorKeeper() should tell**
    provider:: 

     0x14723a09acff6d2a60dcdf7aa4aff308fddc160c

    that the receiver::

     0xca35b7d915458ef540ade6068dfe2f44e8fa733c

    is valid to connect to frontend AP by returning::

     letIn true

5. Demonstration of fuse() from Receiver's perspective
------------------------------------------------------
**Call fuse() as**
    receiver::
    
     0xca35b7d915458ef540ade6068dfe2f44e8fa733c
    
    reports 511 MB data usage with time stamp 1000

    .. tip::

        input this to fuse() box for receiver::

         511,1000

6. Demonstration of fuse() from Provider's perspective
------------------------------------------------------
**Call fuse() as**
    provider::
    
     0x14723a09acff6d2a60dcdf7aa4aff308fddc160c
    
    reports 511 MB data usage from 
    
    receiver::
    
     0xca35b7d915458ef540ade6068dfe2f44e8fa733c

    .. tip::

        Input this into fuse() for provider::

         0xca35b7d915458ef540ade6068dfe2f44e8fa733c,511,1000
     
**Then, check agreement log**
    1st position::

     0x14723a09acff6d2a60dcdf7aa4aff308fddc160c
    
    2nd position::

     0xca35b7d915458ef540ade6068dfe2f44e8fa733c

    .. tip::

        Input::

         "0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C","0xca35b7d915458ef540ade6068dfe2f44e8fa733c"

    **The agreement should be 511 MB**

7. Demonstration of payAndLeave()   
---------------------------------
**Check provider's balance.**

    provider::

     0x14723a09acff6d2a60dcdf7aa4aff308fddc160c

    has **0** token balance.

**Call payAndLeave() function as**

    receiver::

     0xca35b7d915458ef540ade6068dfe2f44e8fa733c

    **51100** DataToken should be paid.

**After the payment, check provider's balance**

    provider:: 

     0x14723a09acff6d2a60dcdf7aa4aff308fddc160c

    has **51100** of token balance.