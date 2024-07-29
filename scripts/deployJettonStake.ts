import { Address, toNano } from '@ton/core';
import { JettonStake } from '../wrappers/JettonStake';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const jettonStake = provider.open(await JettonStake.fromInit(
        Address.parse("EQBd0hSwUhvPnMeoV7BCgtPSq66avKw3gdILFnIcNpqE9dcj")
    ));

    await jettonStake.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: "Deploy",
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(jettonStake.address);

    // run methods on `jettonStake`
}
