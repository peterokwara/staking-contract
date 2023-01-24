// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingContract is ERC20 {
    mapping(address => uint256) public staked;
    mapping(address => uint256) private stakedFromTs;

    constructor() ERC20("StakingContract", "STX") {
        _mint(msg.sender, 1000000000000000000);
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
        uint256 rewards = (staked[msg.sender] * secondsStaked) / 3.154e7;
        _mint(msg.sender, rewards);
        stakedFromTs[msg.sender] = block.timestamp;
    }
}
