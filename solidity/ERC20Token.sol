// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./IERC20.sol";

contract ERC20Token is IERC20, Ownable, SafeMath {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public _totalSupply;
    
    mapping(address => uint256) private coinBalance;
    mapping(address => mapping(address => uint256)) private allowances;
    constructor() public {
        symbol = "CFT";
        name = "CrowdFundingToken";
        decimals = 2;
        _totalSupply = 0;
        owner = msg.sender;
        coinBalance[owner] = _totalSupply;
        _mint(owner,_totalSupply);
    }

    function totalSupply() view public returns (uint256) {
        return _totalSupply - coinBalance[owner];
    }

    function balanceOf(address _account) view public returns (uint256){
        return coinBalance[_account];
    }
    function transfer(address _recipient, uint256 _amount) public returns (bool) {
        require(_amount != 0x0);
        coinBalance[msg.sender] = safeSub(coinBalance[msg.sender], _amount);
        coinBalance[_recipient] = safeAdd(coinBalance[_recipient], _amount);
        emit Transfer(msg.sender, _recipient, _amount);
        return true;
    }
    function allowance(address _authorizer, address _authorizedAccount) view public returns (uint256){
        return allowances[_authorizer][_authorizedAccount];
    }

    function approve(address _spender, uint256 _amount) public returns (bool){
        allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
    function transferFrom(address _sender, address _recipient, uint256 _amount) public returns (bool){
        coinBalance[_sender] = safeSub(coinBalance[_sender], _amount);
        coinBalance[_recipient] = safeAdd(coinBalance[_recipient], _amount);
        allowances[_sender][msg.sender] = safeSub(allowances[_sender][msg.sender], _amount);
        emit Transfer(_sender,_recipient,_amount);
        return true;
    }
      
    function _mint(address _recipient, uint256  _amount) onlyOwner public  { 
        coinBalance[_recipient] += _amount;
        _totalSupply += _amount;
        emit Transfer(owner, _recipient, _amount);
    }
 }