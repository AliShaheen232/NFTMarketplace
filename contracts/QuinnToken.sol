// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity ^0.8.0;

contract QuinnToken is ERC20{
    // mapping (uint=>address) public amount;
    constructor() ERC20 ("Quinn","QIN"){
        _mint(msg.sender, 100000000000000000000000 );
    }
}

