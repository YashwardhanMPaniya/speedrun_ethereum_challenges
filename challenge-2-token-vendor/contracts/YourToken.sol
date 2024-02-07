pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// learn more: https://docs.openzeppelin.com/contracts/4.x/erc20
// deployer 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
contract YourToken is ERC20 {
	constructor() ERC20("Jojo", "JJ") {
		_mint(msg.sender, 2000 * 10 ** 18);
	}
}
