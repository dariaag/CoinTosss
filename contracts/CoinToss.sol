pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


contract CoinToss is VRFConsumerBaseV2 {
  VRFCoordinatorV2Interface COORDINATOR;

  //subscription ID.
  uint64 s_subscriptionId;

  // Goerli
  address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;

  
  bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

  uint32 callbackGasLimit = 100000;
  //default
  uint16 requestConfirmations = 3;


  uint32 numWords =  2;

  uint256[] public s_randomWords;
  uint256 public s_requestId;
  address s_owner;

  constructor(uint64 subscriptionId) payable VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_owner = msg.sender;
    s_subscriptionId = subscriptionId;
  }

  // Assumes the subscription is funded sufficiently.
  function requestRandomWords() public {
    // Will revert if subscription is not set and funded.
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
  }

  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    s_randomWords = randomWords;
  }


  function deposit() public payable returns(uint256){
    uint256 toss = 0;
    uint256 amount = msg.value;
    require(address(this).balance > amount, "insufficient amount");
      requestRandomWords();
      toss = s_randomWords[0] % 1000;
      if (toss <= 499) {
        payable(msg.sender).transfer(amount);
        payable(msg.sender).transfer(amount);
      }
    
    return toss;
  }

  receive() external payable {}



  modifier onlyOwner() {
    require(msg.sender == s_owner);
    _;
  }
}
