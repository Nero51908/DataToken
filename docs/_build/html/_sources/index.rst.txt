.. DataTokenAlpha documentation master file, created by
   sphinx-quickstart on Tue Mar  6 19:12:07 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to DataTokenAlpha!
==========================

This is the documentation of DataTokenAlpha.

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

Terms and Conventions
=====================
In the context of DataTokenAlpha contract, each Ethereum address 
has three possible roles:

* Receiver (Default role)
* Provider (A receiver can switch user role as provider)
* Paired (A receiver who is using AP service of a provider)

.. note::
    Both "receiver" and "paired" are referred to as "receiver" in the following documentation. User `identification`_ value will distinguish paired receiver from unpaired receiver.

Camel case names for variable and function names.
Internal functions all start with an underscore _.
Input parameter of functions starts with an underscore _.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   ContractVariables
   InternalFunctions
   PublicFunctions
