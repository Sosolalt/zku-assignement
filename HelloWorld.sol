// SPDX-License-Identifier: GPL-3.0 
pragma solidity >=0.6.0;
contract HelloWorld{ // defines a contract named `HelloWorld`
    

    uint public number; // declares a state public variable `number` of type `uint`

    function store(uint _number) public {
        number = _number; // declares a function which allows us to give a value to our number
    }

    function get() public view returns (uint) {
        return number; // declares a function which allows us to retrieve our number

    }

}

