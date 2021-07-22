// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;


interface FundingToken {
  
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
  
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    
    function _mint(address _recipient, uint256  _amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    
  
}


contract CrowdFund {
    address public owner;
    address public beneficiary; 
    uint public fundingGoal;
    uint public donationReceived;
    uint public deadline;
    uint public price;
    FundingToken public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool public fundingGoalReached;
    bool public crowdfundingClosed;
    
    event GoalReached(address ownerAddress, uint amountRaisedValue);
    event FundTransfer(address backer, uint amount, bool isContribution);
    event FundReset(bool crowdfundingClosed, bool fundingGoalReached, uint donationReceived);
    
    constructor(address _beneficiary, address _tokenAddress) public {
        owner = msg.sender;
        beneficiary = _beneficiary;
        fundingGoal = 5 * 1 ether;
        deadline = now + 3 * 1 minutes;
        price = 1000000000000000;
        tokenReward = FundingToken(_tokenAddress);
        donationReceived = 0;
        fundingGoalReached = false;
        crowdfundingClosed = false;
    }

    function() payable external {
        require(!crowdfundingClosed); 
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        donationReceived += amount;
        tokenReward.transfer(msg.sender, amount / price);
        
        emit FundTransfer(msg.sender, amount, true);
    }

 
    modifier afterDeadline() {
        require(now >= deadline);
        _;
    }
    function checkGoalReached() afterDeadline public{
        require(!crowdfundingClosed);
        
        if (donationReceived >= fundingGoal){
            fundingGoalReached = true;
            emit GoalReached(beneficiary, donationReceived);
        }
        crowdfundingClosed = true;

    }

    function safeWithdraw() afterDeadline public{
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    emit FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }
        if (fundingGoalReached) {
            if (beneficiary.send(donationReceived)) {
                emit FundTransfer(beneficiary, donationReceived, false);
            } 
            fundingGoalReached = false;
        }
    }
    
    function fundingReset() public {
        crowdfundingClosed =false;
        fundingGoalReached = false;
        donationReceived = 0;
        emit FundReset(crowdfundingClosed, fundingGoalReached, donationReceived);
    }
    

} 