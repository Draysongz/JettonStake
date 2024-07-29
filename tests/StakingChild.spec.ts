import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { StakingChild } from '../wrappers/StakingChild';
import '@ton/test-utils';

describe('StakingChild', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let stakingChild: SandboxContract<StakingChild>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        stakingChild = blockchain.openContract(await StakingChild.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await stakingChild.send(
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
            to: stakingChild.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and stakingChild are ready to use
    });
});
