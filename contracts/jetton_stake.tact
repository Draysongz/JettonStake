import "@stdlib/deploy";
import "../contracts/staking_child.tact";

struct Metadata {
    symbol: String;
    totalStaked: Int;
}

message CreateAggregtor{
    owner: Address;
}


contract JettonStake with Deployable {
    symbol: String;
    totalStaked: Int as coins;
    rewardTokenAddress: Address; // Address of the reward token contract
    rewardTokenBalance: Int as coins;

    
    init(rewardToken: Address) {
        self.symbol = "TON";
        self.totalStaked= 0;
        self.rewardTokenAddress= rewardToken;
        self.rewardTokenBalance = 0;
    }



 fun createStakingChild(to: Address): Address {
        let init: StateInit = initOf StakingChild(myAddress(), to, self.rewardTokenAddress);
        send(SendParameters{
            to: contractAddress(init),
            value: ton("0.03"),
            mode: SendIgnoreErrors,
            code: init.code,
            data: init.data
        });

        return contractAddress(initOf StakingChild(myAddress(), to, self.rewardTokenAddress));
    }


    

    receive (msg: CreateAggregtor){
        self.createStakingChild(msg.owner);   
    }

    receive(msg: TransferReward) {
        require(msg.amount <= self.rewardTokenBalance, "Insufficient reward balance");
        self.rewardTokenBalance = self.rewardTokenBalance - msg.amount;
        send(SendParameters{
            to: msg.to,
            value: msg.amount,
            mode: SendIgnoreErrors
        });
    }


    receive(msg: UpdateTotalStaked) {
        self.totalStaked = self.totalStaked + msg.amount;
    }

    get fun metadata(): Metadata {
        return Metadata{symbol: self.symbol, totalStaked: self.totalStaked};
    }

    get fun childAddress(owner: Address): Address {
        return contractAddress(initOf StakingChild(myAddress(), owner, self.rewardTokenAddress));
    }

    receive(msg: Stake) {
        self.totalStaked += msg.amount; // Update the reward token balance
    }

}
