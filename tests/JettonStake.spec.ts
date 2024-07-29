import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { JettonStake } from '../wrappers/JettonStake';
import '@ton/test-utils';

describe('JettonStake', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let jettonStake: SandboxContract<JettonStake>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        jettonStake = blockchain.openContract(await JettonStake.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await jettonStake.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: jettonStake.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and jettonStake are ready to use
    });
});
