import { toNano } from '@ton/core';
import { StakingChild } from '../wrappers/StakingChild';
import { NetworkProvider } from '@ton/blueprint';
import { firstChildAddress } from '../stakeConstants';
import { sleep } from '../stakeConstants';

export async function run(provider: NetworkProvider) {
    const stakingChild = provider.open(await StakingChild.fromAddress(firstChildAddress));

    const stakedBalanceBefore = await stakingChild.getStakedBalance()
    console.log("staked balance before staking: ", stakedBalanceBefore);

    await stakingChild.send(
        provider.sender(),
        {
            value: toNano("1.05")
        },
        {
            $$type: "Stake",
            amount: toNano("1")
        }      
    )

    let stakedBalanceAfter = await stakingChild.getStakedBalance()
    let attempt = 1

    while(stakedBalanceBefore === stakedBalanceAfter){
    console.log("Staking, attempt", attempt)
    await sleep(2000);
    stakedBalanceAfter = await stakingChild.getStakedBalance()
    attempt++
}



    console.log("balance after staking : ", stakedBalanceAfter);

}
