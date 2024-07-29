import { Address, toNano } from '@ton/core';
import { JettonStake } from '../wrappers/JettonStake';
import { NetworkProvider } from '@ton/blueprint';
import { parentContractAddress } from '../stakeConstants';

export async function run(provider: NetworkProvider) {
    const jettonStake = provider.open(await JettonStake.fromAddress(parentContractAddress));


    await jettonStake.send(
        provider.sender(),
        {
            value: toNano("0.05")
        },
        {
            $$type: "CreateAggregtor",
            owner: provider.sender().address!!
        }
    )

}
