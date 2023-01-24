// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingContract is ERC20 {
    address private contractOwner;
    mapping(address => uint256) public staked;
    mapping(address => uint256) private stakedFromTs;

    bool private operational = true;

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

     /**
     * @dev Modifier that requires the "operational" boolean variable to be "true"
     */
    modifier requireIsOperational() {
        require(isOperational(), "Contract is currently not operational");
        _;
    }

    /**
     * @dev Get the operating status of a contract
     * @return boolean A value that states if the contract is operational or not
     */
    function isOperational() public view returns (bool) {
        return operational;
    }

    /**
     * @dev Set the operating status of the contract
     */
    function setOperatingStatus(bool mode) external requireContractOnwer {
        operational = mode;
    }
            
    function setApy(uint256 _apy) public requireContractOnwer requireIsOperational {
        require(_apy > 0, "The APY must be greater than zero");
        apy = _apy;
    }

    function stake(uint256 amount) external requireIsOperational {
        require(amount > 0, "amount is <= 0");
        require(balanceOf(msg.sender) >= amount, "balance is <= amount");
        _transfer(msg.sender, address(this), amount);
        if (staked[msg.sender] > 0) {
            claim();
        }

        stakedFromTs[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
    }

    function unstake(uint256 amount) external requireIsOperational {
        require(amount > 0, "amount is <= 0");
        require(staked[msg.sender] >= amount, "amount is > staked");
        claim();
        staked[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);
    }

    function claim() public requireIsOperational {
        require(staked[msg.sender] > 0, "staked is <= 0");
        uint256 secondsStaked = block.timestamp - stakedFromTs[msg.sender];
        uint256 rewards = (staked[msg.sender] * apy * secondsStaked) / (3.154e7 * 100);
        _mint(msg.sender, rewards);
        stakedFromTs[msg.sender] = block.timestamp;
    }
}
