pragma solidity ^0.4.16;


contract ArrayStructureExperiment{
    //user can register many address as etherBase
    struct User{
          string userID;
          address[] etherBase;
          bool identity;//guest = 0 (flase) or host = 1 (true)
        }
    
    mapping(address=>mapping(address=>bool)[]) public host_guest;//host address can have multiple guests, each guest have a state paid or not.

    function examine(address _host, address _guest) public {
        host_guest[_host][_guest] = 
    }
    
       
}