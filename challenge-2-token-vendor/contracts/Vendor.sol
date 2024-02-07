pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
	event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event SellTokens(
		address seller,
		uint256 amountOfTokens,
		uint256 amountOfETH
	);

	YourToken public yourToken;
	uint256 public constant tokensPerEth = 100;

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// ToDo: create a payable buyTokens() function:

	function buyTokens() public payable {
		//validate the user send eth
		uint256 amountOfETH = msg.value;
		require(amountOfETH > 0, "send some ETH, not enough");

		//check vendor has enough token
		uint256 amountOfTokens = amountOfETH * tokensPerEth;
		uint256 vendorBalance = yourToken.balanceOf(address(this));
		require(
			vendorBalance >= amountOfTokens,
			"vendor dont have enough token"
		);

		//send token
		bool send = yourToken.transfer(msg.sender, amountOfTokens);
		require(send, "failed to send token");

		//emit event
		emit BuyTokens(msg.sender, amountOfETH, amountOfTokens);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH

	function withdraw() public onlyOwner {
		//validate contract has eth to withdraw
		uint256 vendorBalance = address(this).balance;
		require(vendorBalance > 0, "Vendor Contract does not have any eth");

		//tarnsfer eth
		(bool sent, ) = (msg.sender).call{ value: vendorBalance }("");
		require(sent, "failed to transfer");
	}

	/// Allow users to sell tokens back to the vendor
	function sellTokens(uint256 amount) public {
		// Validate token amount
		require(amount > 0, "Must sell a token amount greater than 0");

		// Validate the user has the tokens to sell
		address user = msg.sender;
		uint256 userBalance = yourToken.balanceOf(user);
		require(userBalance >= amount, "User does not have enough tokens");

		// Validate the vendor has enough ETH
		uint256 amountOfEth = amount / tokensPerEth;
		uint256 vendorEthBalance = address(this).balance;
		require(
			vendorEthBalance >= amountOfEth,
			"Vendor does not have enough ETH"
		);

		// Transfer tokens
		bool sent = yourToken.transferFrom(user, address(this), amount);
		require(sent, "Failed to transfer tokens");

		// Transfer ETH
		(bool ethSent, ) = user.call{ value: amountOfEth }("");
		require(ethSent, "Failed to send back eth");

		// Emit sell event
		emit SellTokens(user, amountOfEth, amount);
	}
}
