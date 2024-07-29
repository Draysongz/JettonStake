import { toNano } from '@ton/core';
import { StakingChild } from '../wrappers/StakingChild';
import { NetworkProvider } from '@ton/blueprint';
import { firstChildAddress } from '../stakeConstants';
import { sleep } from '../stakeConstants';

export async function run(provider: NetworkProvider) {
    const stakingChild = provider.open(await StakingChild.fromAddress(firstChildAddress));

    const stakedBalanceBefore = await stakingChild.getStakedBalance()
    console.log("staked balance before Unstaking: ", stakedBalanceBefore);

    await stakingChild.send(
        provider.sender(),
        {
            value: toNano("0.05")
        },
        {
            $$type: "Unstake",
            amount: toNano("0.2")
        }      
    )

    let stakedBalanceAfter = await stakingChild.getStakedBalance()
    let attempt = 1

    while(stakedBalanceBefore === stakedBalanceAfter){
    console.log("Unstaking, attempt", attempt)
    await sleep(2000);
    stakedBalanceAfter = await stakingChild.getStakedBalance()
    attempt++
}



    console.log("balance after Unstaking : ", stakedBalanceAfter);

}
