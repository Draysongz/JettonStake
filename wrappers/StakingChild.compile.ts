import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/staking_child.tact',
    options: {
        debug: true,
    },
};
