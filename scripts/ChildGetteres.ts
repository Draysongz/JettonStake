import { toNano } from '@ton/core';
import { StakingChild } from '../wrappers/StakingChild';
import { NetworkProvider } from '@ton/blueprint';
import { firstChildAddress } from '../stakeConstants';
import { sleep } from '../stakeConstants';

export async function run(provider: NetworkProvider) {
    const stakingChild = provider.open(await StakingChild.fromAddress(firstChildAddress));

    const stakedBalanceBefore = await stakingChild.getStakedBalance()
    console.log("staked balance before staking: ", stakedBalanceBefore);

   const rewardBalance = await stakingChild.getRewardBalance();


   console.log("rewardBalance is : ", rewardBalance);

}
