## **Crowd Funding**

아래는 크라우드 펀딩에 대한 간단한 설명이다.

### **1.1 소개**

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/40646b3b-2f82-4f82-b1c6-509123fecdb8/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/40646b3b-2f82-4f82-b1c6-509123fecdb8/Untitled.png)

크라우드펀딩은 군중 또는 다수를 의미하는 영어 단어 크라우드(Crowd)와 자금조달을 뜻하는 펀딩(Funding)을 조합한 용어이다. 창의적 아이템을 가진 초기 기업가를 비롯한 자금수요자가 중개업자(온라인소액투자중개업자)의 온라인 플랫폼에서 집단지성 (The Wisdom of Crowds)을 활용하여 다수의 소액투자자로부터 자금을 조달하는 행위 를 크라우드펀딩이라 한다.

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/7a50e12c-6fc5-4866-9c33-b02ce2019edd/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/7a50e12c-6fc5-4866-9c33-b02ce2019edd/Untitled.png)

### **1.2 요구사항**

이 DAPP 개발에서 필요한 요구사항을 정리하면 아래와 같다.

- 총 모금액은 500이더이다. 이를 넘으면 더 이상 펀드를 받지 않는다.
- 모금 기간은 분 단위로 지정한다.
- EOA가 펀드에 청약하면 신청한 금액에 해당하는 증표로 토큰을 발행한다.
- 펀드 금액과 토큰 비율은 1:1000로 한다.
- 모금 기간 안에 목표 금액을 달성하면 의료 기관에 모금 금액 전부를 송금한다.
- 모금 기간이 지나도 목표 금액이 달성되지 않으면 청약자들에게 신청 금액을 모두 반환한다.

### **1.3 개발** **환경**

이 DAPP 개발에 필요한 개발 환경을 정리하면 아래와 같다.

```bash
$ lsb_release -a
No LSB modules are ava8ilable.
DistributorID: Ubuntu
Description: Ubuntu 18.04.5 LTS
Release: 18.04
Codename: bionic
$ node -v
v12.22.1
$ npm -v
6.14.12
$ git version
git version 2.17.1
$ ls Downloads/ganache-2.5.4-linux-x86_64.AppImage
ganache-2.5.4-linux-x86_64.AppImage

+ chrome
+ remix.ethereum.org
```

### 1.4 Solidity 소스파일 경로

```bash
$ pwd 
/home/ether/crowdfund-project

$ ls crowdfund-project/
app.js  bin  dapp  data  node_modules  package.json  package-lock.json  poc-data  
public  README.md  routes  solidity  views

$ ls solidity/
CrowdFund.sol  ERC20Token.sol  IERC20.sol  Ownable.sol  SafeMath.sol
```

# 2. Token 생성

아래는 이더리움 기반 Token 생성에 필요한 컨트랙에 대한 설명이다.

## 2.1 IERC20 인터페이스

```jsx
$ cat /home/ether/crowdfund-project/solidity/IERC20.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
```

다른 ERC20 토큰과 호환되도록 토큰을 만들려면 IERC20 인터페이스를 상속받아 작성해야 한다.

7

## 2.2 Ownable contract

```jsx
$ cat /home/ether/crowdfund-project/solidity/Ownable.sol

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract Ownable{
	address internal owner;
    constructor() public {
        owner = msg.sender;
    }
	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}
```

modifier를 통해 컨트랙트를 배포한 계정만 사용할 수 있도록 제한한다.

## 2.3 SafeMath contract

```jsx
$ cat /home/ether/crowdfund-project/solidity/SafeMath.sol

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract SafeMath {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}
```

사칙연산을 할 때 매번 require을 이용해서 매번 검사 코드를 작성해야 한다. SafeMath를 작성하여 안정성 검사에 대한 부담을 덜 수 있다.

## 2.4 ERC20 토큰 구현

다른 ERC20 토큰과 호환되도록 토큰을 만들려면 IERC20 인터페이스를 상속받아 작성해야 한다.

```jsx
$ cat /home/ether/crowdfund-project/solidity/ERC20Token.sol

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
```

토큰의 추가 기능을 구현할 때, ERC20기반 토큰은 ERC20Token 컨트랙트를 상속받아 작성한다.

### 2.5 지갑과 호환되는 토큰을 만들기 위해 필요한 요소

```jsx
string public symbol;
string public name;
uint8 public decimals;
```

# 3. CrowdFund contract

### 3.1 전체코드

```jsx
$ cat /home/ether/crowdfund-project/solidity/ERC20Token.sol

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
```

### 3.2 토큰 컨트랙트 인스턴스 주소를 받기 위한 토큰 인터패이스

```jsx

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

FundingToken public tokenReward;
tokenReward = FundingToken(_tokenAddress);
```

블록체인에 배포된 토큰 컨트랙트 인스턴스를 인터페이스를 통해 토큰 컨트랙트 주소를 바인딩하여 사용 할 수 있다.

### 3.3 생성자

```jsx

    constructor(address _beneficiary, address _tokenAddress) public {
        owner = msg.sender;
        beneficiary = _beneficiary;
        fundingGoal = 10 ether;
        deadline = now + 1 weeks;
				donationReceived = 0;
        price = 1000000000000000;
        tokenReward = FundingToken(_tokenAddress);
        
        fundingGoalReached = false;
        crowdfundingClosed = false;
    }

```

owner, beneficiary, fundingGoal, deadline, donationReceived 는 컨트랙트를 배포한 주소, 펀딩 을 마감한 이후 펀딩금을 가져가는 주소, 목표금액, 펀딩 기간, 받은 후원금을 등록한다. 그리고, price 로 이더와 토큰의 비율을 1 : 1000 설정한다. 또한, fundingGoalReached, crowdfundingClosed는 펀딩금액에 도달했는지 나타내는 플래그, 클라우드펀딩이 종료됬는지 나타내는 플래그이다.

### 3.4 컨트랙트에 이더를 받는 payable함수

```jsx
    function() payable external {
        require(!crowdfundingClosed); 
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        donationReceived += amount;
        tokenReward.transfer(msg.sender, amount / price);
        
        emit FundTransfer(msg.sender, amount, true);
    }

```

Ether를 받아 컨트랙트에 저장하고 토큰을 반환한다.

### 3.5 접근을 제한하는 함수 변경자

```jsx
    modifier afterDeadline() {
        require(now >= deadline);
        _;
    }
```

클라우드 펀딩 마감일이 지났는지 현재 시간과 비교하여 확인한다.

### 3.6 목표금액에 도달했는지 확인하는 함수

```jsx
 function checkGoalReached() afterDeadline public{
        require(!crowdfundingClosed);
        
        if (donationReceived >= fundingGoal){
            fundingGoalReached = true;
            emit GoalReached(beneficiary, donationReceived);
        }
        crowdfundingClosed = true;

    }
```

afterDeadline modifier를 통해 마감시간을 검사하고 crowdfundingclosed 플래그로 클라우드 펀드 가 진행중인지 확인한다. 총 후원금이 목표금액보다 클 경우 fundingGoalReached 플래그를 변경하 고 GoalReached이벤트를 발생시켜 로그를 출력한다. 그리고 crowdfundingClosed플래그로 클라 우드 펀딩이 종료되었다는 것을 나타낸다.

### 3.7 클라우드 펀딩금을 인출하는 함수

```jsx
		function safeWithdraw() afterDeadline public{
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    donationReceived -= amount;
                    emit FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }
        if (fundingGoalReached) {
            if (beneficiary.send(donationReceived)) {
                donationReceived = 0;
                emit FundTransfer(beneficiary, donationReceived, false);
            } 
            else{
                fundingGoalReached = false;    
            }
        }
    }
```

펀딩금액에 도달했을 경우 beneficiary 지갑주소로 모든 펀딩 금액이 전송된다. 도달하지 못했을 경우 펀딩 참가자에게 되돌아 간다.

### 3.8 클라우드 펀딩을 다시 할수 있게 하는 함수

```jsx
function fundingReset() public {
	require(donationReceived == 0);
  crowdfundingClosed =false;
  fundingGoalReached = false;
  emit FundReset(crowdfundingClosed, fundingGoalReached, donationReceived);
}
```

인출 후 닫힌 펀딩을 다시 열고 목표 펀딩 플래그를 복귀시킨다. 또한, 기부금액을 초기화하고 이벤트를 발생시킨다. 인출 후 컨트랙트를 사용하지 못하게 되어 추가했다.

## 3. Remix 배포 과정

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/fde46768-2023-4a52-95fc-6ee9b4cd963d/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/fde46768-2023-4a52-95fc-6ee9b4cd963d/Untitled.png)

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/24fd0e87-3539-48bb-a275-37fadab73bc1/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/24fd0e87-3539-48bb-a275-37fadab73bc1/Untitled.png)

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/6eb15459-8b76-4979-9138-ed89d9d9f788/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/6eb15459-8b76-4979-9138-ed89d9d9f788/Untitled.png)

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/e08489ec-f782-4e2f-b7c4-f8c4832f5114/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/e08489ec-f782-4e2f-b7c4-f8c4832f5114/Untitled.png)

IERC20.sol은 interface이므로 배포하지 않는다. ERC20Tonken 컨트렉트에서는 SafeMath, Owanable 컨트랙트를 상속 받기 때문에, SafeMath, Ownable를 배포한 후 ERC20Token을 배포해야 한다. CrowdFund는 ERC20Token의 CA와 펀딩금을 받을 EOA를 입력해서 배포한다.

### 3.1 Remix Deployed Contract 결과

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/a5a8d16d-9978-41b1-9e7b-5f280a6b24bd/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/a5a8d16d-9978-41b1-9e7b-5f280a6b24bd/Untitled.png)

remix에서 배포하면 아래 처럼 배포된 컨트랙트의 변수와 함수를 확인해 볼수 있다.

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/4c6c4751-c959-4c23-8d81-dc94e88e89e4/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/4c6c4751-c959-4c23-8d81-dc94e88e89e4/Untitled.png)

CrowdFunding Contract address에 FundingToken을 전송함으로써 솔리디티 배포를 마친다.

- 직접 Token 전송을 함수로 만들어서 사용하려는 시도

```jsx
function takeToken() public {
	tokenReward._mint(address(this), 100000);
}

- 결과 -
**Error**
Gas estimation failed
Gas estimation errored with the following message (see below). 
The transaction execution will likely fail. Do you want to force sending?
Returned error: VM Exception while processing transaction: revert

```

### 3.2 Remix에서 확인되는 트랙잭션

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/9514ffdf-da18-403b-846b-d69b1cc6bf8e/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/9514ffdf-da18-403b-846b-d69b1cc6bf8e/Untitled.png)

위의 배포과정에서 생성된 트랜잭션을 확인할 수 있다.

### 3.3 Token contract를 Ganache 네트워크에 배포 트랜잭션

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/7962c7a4-f926-4880-9eb7-914697401cc6/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/7962c7a4-f926-4880-9eb7-914697401cc6/Untitled.png)

### 3.4 CrowdFund contract를 Ganache 네트워크에 배포 트랜잭션

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/f3ac1257-9f6a-4163-916f-7a0cb3711eb4/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/f3ac1257-9f6a-4163-916f-7a0cb3711eb4/Untitled.png)

### 3.5 Remix에서 Token contract의 mint 로 CrowdFund contract에 토큰 생성

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/3382bec6-8904-4b79-8f72-1e6770d725e5/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/3382bec6-8904-4b79-8f72-1e6770d725e5/Untitled.png)

# 4. JavaScript

### 4.1 JS에서 사용하는 EOA및 CA 주소

```jsx
$ cat /home/ether/crowdfund-project/dapp/constant.js
exports.mainAddress = "0xF3f3E1535d3F01E19cc2c8627aA9BD48FF52CF81"; // 토큰 생성 계정
exports.makerAddress = "0x0396c0E94451548C1C0F2026FEC6D2E2dA665FA6"; // 제작자 계정
exports.eoaAddress = "0xAD290b4C5a65D559a166936776b5716d812a9F31"; // 참여자 계정
exports.TokenContractAddress = "0x784D9f77D50C7BeAd5e8cB452F8535dD3c7DF838"; // 토큰 계정
exports.crowdFundContractAddress = "0xc97235eE2225Ccbb9F38CD7c496b29686Ab4b205"; // 펀딩 계정
```

### 4.2 다른 JS파일로 constant.js파일 가져오기

```jsx
$ cat /home/ether/crowdfund-project/dapp/eth.js

var constant = require("./constant.js");
const mainAddress = constant.mainAddress;
const makerAddress = constant.makerAddress;
const eoaAddress = constant.eoaAddress;
const TokenContractAddress = constant.TokenContractAddress;
const crowdFundContractAddress = constant.crowdFundContractAddress;
```

Node.JS의 require 메서드를 통해 외부 모듈인 constant.js에서 소스파일을 읽어서 저장한다.

### 4.3 배포된 컨트랙트를 JS에서 사용

```jsx
var walletTokenAbi =  ERC20Token contract ABI를 입력한다.
var crowdFundAbi = CrowdFund contract ABI를 입력한다.

var TokenContract = web3.eth.contract(walletTokenAbi).at(TokenContractAddress);
var CrowdFundContract = web3.eth.contract(crowdFundAbi).at(crowdFundContractAddress);

web3.eth.defaultAccount = web3.eth.accounts[0];
```

컨트랙트 ABI와 컨트랙트 Address를 통해 사용할 컨트랙트를 변수에 저장한다. 그리고 web3를 사용할 Account를 지정한다.

### 4.4 실행 명령어

```bash
$ pwd
/home/ether/crowdfund-project
$ npm start
> crowdfund@0.0.0 start
> node ./bin/www
```
