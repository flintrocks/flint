pragma solidity ^0.4.21;

contract Emitter {
    
    event EmitCheck(uint8 _value);

    constructor() public {
    
    }
  
    function emitCheck(uint8 _value) public returns (uint8) {
        emit EmitCheck(_value);
        return 0;
    }
}

