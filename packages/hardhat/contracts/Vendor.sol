pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);

  YourToken public yourToken;
  address _tokenAddress;
  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    //Get the token balance
    _tokenAddress = tokenAddress;
    //Initialize the token
    yourToken = YourToken(tokenAddress);
  }

  function buyTokens() external payable {
    require(msg.value > 0, "Ether must be greater than 0");

    uint256 amountOfTokens = msg.value * tokensPerEth;
    
    //Check if the contract has enough contracts
    // require(tokenBalance > amountOfTokens, "Not enough tokens in the contract");
    //Transfer Tokens
    bool success = yourToken.transfer(msg.sender, amountOfTokens);
    require(success, "Token Transfer failed");
    
    //Emit event
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() external onlyOwner {
    uint256 contractBalance = address(this).balance;
    require(contractBalance > 0, "Contract Balance is too low");

    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success, "Withdrawal Failed");
  }

  // ToDo: create a sellTokens(uint256 _amount) function:
  function sellTokens(uint256 _amount) external {
    require(_amount > 0, "Amount must be greater than zero");

    //Calculate Ether to be sent to the user
    uint256 ethToPay = _amount / tokensPerEth;
    require(address(this).balance >= ethToPay, "Contract does not have enough ether");

    bool transferSuccess = yourToken.transferFrom(msg.sender, address(this), _amount);
    require(transferSuccess, "Unable to sell Tokens");

    // pay the user
    (bool success, ) = payable(msg.sender).call{value: ethToPay}("");
    require(success, "Unable to send ether to sender");
  }

  receive() external payable {

  }
}
