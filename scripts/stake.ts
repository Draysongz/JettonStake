
import { Address, toNano } from '@ton/core';
import { JettonStake } from '../wrappers/JettonStake';
import { NetworkProvider } from '@ton/blueprint';
import { parentContractAddress } from '../stakeConstants';
import { sleep } from '../stakeConstants';

export async function run(provider: NetworkProvider) {
    const jettonStake = provider.open(await JettonStake.fromAddress(parentContractAddress));

    const stakedBalanceBefore = (await jettonStake.getMetadata()).totalStaked

    await jettonStake.send(
        provider.sender(),
        {
            value: toNano('1.06'),
        },
        {
            $$type: "Stake",
            amount: toNano("1")
        }
    );

    let stakedBalanceAfter = (await jettonStake.getMetadata()).totalStaked
    let attempt = 1

    while(stakedBalanceBefore === stakedBalanceAfter){
    console.log("Staking, attempt", attempt)
    await sleep(2000);
    stakedBalanceAfter = (await jettonStake.getMetadata()).totalStaked
    attempt++
}



    console.log("balance after staking : ", stakedBalanceAfter);
}
