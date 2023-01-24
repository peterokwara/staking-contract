// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingContract is ERC20 {
    address private contractOwner;
    mapping(address => uint256) public staked;
    mapping(address => uint256) private stakedFromTs;

    uint256 public apy; 

    constructor() ERC20("StakingContract", "STX") {
        contractOwner = msg.sender;
        _mint(msg.sender, 1000000000000000000);

        // Set default apy value to 10
        apy = 10;
    }

    modifier requireContractOnwer(){
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }
            
    function setApy(uint256 _apy) public requireContractOnwer {
        require(_apy > 0, "The APY must be greater than zero");
        apy = _apy;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "amount is <= 0");
        require(balanceOf(msg.sender) >= amount, "balance is <= amount");
        _transfer(msg.sender, address(this), amount);
        if (staked[msg.sender] > 0) {
            claim();
        }

        stakedFromTs[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "amount is <= 0");
        require(staked[msg.sender] >= amount, "amount is > staked");
        claim();
        staked[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);
    }

    function claim() public {
        require(staked[msg.sender] > 0, "staked is <= 0");
        uint256 secondsStaked = block.timestamp - stakedFromTs[msg.sender];
        uint256 rewards = (staked[msg.sender] * apy * secondsStaked) / (3.154e7 * 100);
        _mint(msg.sender, rewards);
        stakedFromTs[msg.sender] = block.timestamp;
    }
}
