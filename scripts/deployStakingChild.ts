import { toNano } from '@ton/core';
import { StakingChild } from '../wrappers/StakingChild';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const stakingChild = provider.open(await StakingChild.fromInit());

    await stakingChild.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(stakingChild.address);

    // run methods on `stakingChild`
}
