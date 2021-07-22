// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

contract Ownable{
    
	address internal owner;

    constructor() public {
        owner = msg.sender;
    }

	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
	
}