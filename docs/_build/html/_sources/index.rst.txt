.. DataTokenAlpha documentation master file, created by
   sphinx-quickstart on Tue Mar  6 19:12:07 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to DataTokenAlpha!
==========================

This is the smart contract (API) documentation of DataTokenAlpha (temporary project name). 
The documentation is written presumably that 
the reader has fundamental knowledge about Solidity programming.

.. image:: logo.png
    :scale: 50 %
    :alt: alternate text
    :align: center

Introduction
============

This project, which is developed in Solidity language, aims to implement a scheme (backend service, or API) for peer-to-peer (P2P) cellular data sharing.
Users of this service can use various implementations of frontend (client) softwares to interact with this smart contract on Ethereum.
The contract, DataTokenAlpha (temporary project name) works as a highly trustable automated ledger rather than a third-party owned
by someone else who is probably malicious. Users can act as Wi-Fi service provider to share their cellular data or 
as service receiver to pay for the Wi-Fi services in physical layer; their behaviors, for instance, using data, checking out and invoicing
can be reported by the frontend software they use. By carefully designing the backend contract, malicious (dishonest) behaviors will
lead to extremely inconvenient using experience for both provider type and receiver type of users, therefore, frontend need to behave to some extent.
As a ledger, DataTokenAlpha need a numerical base to record data trading, 
hence, DataToken (temporary name of certain token), a token offered by smart contract DataTokenAlpha is created.
Users of the contract can buy DataToken from the owner of the smart contract with Ether. 
Then, users are able to exchange DataToken with Wi-Fi service or the other way round with other users in real world.
The uniqueness of such implementation is that all information is held immutable by Ethereum 
network based on blockchain technology from brutal force (computational) hacking of current generation computers.
As a result, DataTokenAlpha runs on Ethereum network as a backend is decentralized and more trustable than 
centralized backend services on centralized third-parties.

Terms and Conventions
=====================
In the context of DataTokenAlpha contract, each Ethereum address (user) 
has three possible roles:

* role.isReceiver (Default role assigned to all Ethereum addresses)
* role.isProvider (A receiver can switch user role as provider)
* role.Paired (A receiver who has successfully linked to a provider 
so that the frontend of this receiver should be able to connect the AP provided by certain provider)

.. note::
    Both "receiver" and "paired" are referred to as "receiver" in the following documentation.
    The term "paired" appears when it is necessary to clarify whether a receiver has linked to the service of a provider in backend.
    User `identification`_ value will distinguish paired receiver from unpaired receiver.

Camel case names for variable and function names.
Internal functions all start with an underscore _.
Input parameters of functions all start with an underscore _.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   ContractVariables
   InternalFunctions
   PublicFunctions
   Event
   DemoScript
