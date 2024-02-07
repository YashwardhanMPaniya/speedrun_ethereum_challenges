// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	ExampleExternalContract public exampleExternalContract;

	//state variable
	mapping(address => uint256) public balances;
	uint256 public constant threshold = 1 ether;
	//uint256 public totalAmount;
	uint256 public deadline = block.timestamp + 72 hours;

	bool public canWithdraw = false;

	//Event
	event Stake(address owner, uint256 amount);

	constructor(address exampleExternalContractAddress) {
		exampleExternalContract = ExampleExternalContract(
			exampleExternalContractAddress
		);
	}

	modifier notCompleted() {
		require(!exampleExternalContract.completed(), "Funding Close");
		_;
	}

	function stake() public payable notCompleted {
		// if (deadline > block.timestamp) {
		// 	balances[msg.sender] = msg.value;
		// 	//totalAmount += msg.value;
		// 	emit Stake(msg.sender, msg.value);
		// }
		require(timeLeft() > 0, "Sorry times up");
		balances[msg.sender] += msg.value;
		emit Stake(msg.sender, msg.value);
	}

	function execute() public notCompleted {
		if (block.timestamp >= deadline) {
			if (address(this).balance > threshold) {
				exampleExternalContract.complete{
					value: address(this).balance
				}();
			}
		}
		canWithdraw = true;
	}

	function withdraw() public {
		require(canWithdraw, "Withdraw currently not available");
		(bool success, ) = msg.sender.call{ value: balances[msg.sender] }("");
		require(success, "Failed to send Ether");
	}

	function timeLeft() public view returns (uint256) {
		if (block.timestamp >= deadline) {
			return 0;
		}
		return deadline - block.timestamp;
	}

	function recieve() external payable {
		stake();
	}

	// Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
	// (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

	// After some `deadline` allow anyone to call an `execute()` function
	// If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

	// If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

	// Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

	// Add the `receive()` special function that receives eth and calls stake()
}
