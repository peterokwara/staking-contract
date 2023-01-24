const StakingContract = artifacts.require("StakingContract");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("StakingContract", function (accounts) {
    // Create some test accounts
    const account_one = accounts[0];
    const account_two = accounts[1];
    const account_three = accounts[2];
    const account_four = accounts[3];

    beforeEach(async function () {
        stakingContract = await StakingContract.new({ from: account_one });

        // Supply the second account with some new minted tokens
        await stakingContract.transfer(account_two, 1000000);
    });

    /**
     * Basic test.
     */
    it("should assert true", async function () {
        await StakingContract.deployed();
        return assert.isTrue(true);
    });

    /**
     * Check the contract has the correct name.
     */
    it("should have the correct name", async () => {
        const contractName = await stakingContract.name();
        assert.equal(contractName, "StakingContract", "The contract name should be equal to StakingContract");
    });

    /**
     * Check if it has the correct symbol and supply.
     */
    it("should have the correct symbol and supply", async () => {
        const totalSupply = await stakingContract.totalSupply();
        assert.equal(totalSupply, 1000000000000000000, "The total supply should be equal to 1000000000000000000");
    });

    /**
     * Able to stake correctly
     */
    it("should be able to stake correctly", async () => {
        let initialBalance = await stakingContract.balanceOf(account_two);
        await stakingContract.stake(100, { from: account_two });
        let finalBalance = await stakingContract.balanceOf(account_two);
        assert.equal(
            finalBalance,
            initialBalance - 100,
            "The final balance should be equal to the initial balance minus the staking amout"
        );
    });

    /**
     * Able to unstake correctly
     */
    it("should be able to unstake correctly", async () => {
        await stakingContract.stake(200, { from: account_two });
        const initialBalance = await stakingContract.balanceOf(account_two);
        await stakingContract.unstake(100, { from: account_two });
        const finalBalance = await stakingContract.balanceOf(account_two);

        assert.equal(
            finalBalance - initialBalance,
            100,
            "The diffrerence between the final balance and initial balance should be equal to the unstaked amount"
        );
    });

    /**
     * Able to claim correctly
     */
    it("should be able to claim correctly", async () => {
        await stakingContract.stake(100, { from: account_two });
        let initialBalance = await stakingContract.balanceOf(account_two);

        await increase(31536000);

        await stakingContract.claim({ from: account_two });
        let finalBalance = await stakingContract.balanceOf(account_two);

        assert.ok(finalBalance.gt(initialBalance));
    });

    /**
     * Able to change apy
     */
    it("should be able to change the apy", async () => {
        await stakingContract.setApy(15, { from: account_one });
        const stakingApy = await stakingContract.apy.call();
        assert.equal(stakingApy.toNumber(), 15, "The staking apy should be equal to 15");
    });

    /**
     * Fail to change the apy
     */
    it("should fail to change the apy", async () => {
        let reverted = false;

        try {
            await stakingContract.setApy(0, { from: account_one });
        } catch (error) {
            reverted = true;
        }

        // Should be reverted
        assert.equal(reverted, true, "only the contract owner can change the apy");
    });

    /**
     * Fail to change the apy if the contract is disabled
     */
    it("should fail to change the apy if the contract is disabled ", async () => {
        let reverted = false;

        try {
            await stakingContract.setOperatingStatus(false, { from: account_one });
            await stakingContract.setApy(15, { from: account_one });
        } catch (error) {
            reverted = true;
        }
        assert.equal(reverted, true, "cannot change apy if the smart contract is disabled");
    });

    /**
     * Helper function to increase block time.
     * @param duration The duration in milliseconds to increase the time by.
     * @returns void.
     */
    async function increase(duration) {
        return new Promise((resolve, reject) => {
            web3.currentProvider.send(
                {
                    jsonrpc: "2.0",
                    method: "evm_increaseTime",
                    params: [duration],
                    id: new Date().getTime()
                },
                (err, result) => {
                    // second call within the callback
                    web3.currentProvider.send(
                        {
                            jsonrpc: "2.0",
                            method: "evm_mine",
                            params: [],
                            id: new Date().getTime()
                        },
                        (err, result) => {
                            // need to resolve the Promise in the second callback
                            resolve();
                        }
                    );
                }
            );
        });
    }
});
