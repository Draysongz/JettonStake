import "@stdlib/deploy";

message Stake {
    amount: Int as coins;
}

message Unstake {
    amount: Int as coins;
}

message ClaimReward {
}

message InternalAddTokens {
    amount: Int as coins;
    origin: Address;
}

message UpdateStakeDetails{
    amount: Int;
}

message TransferReward {
    amount: Int as coins;
    to: Address;
}

message(0xf8a7ea5) TokenTransfer {
     queryId: Int as uint64; // should be 0
     amount: Int as coins; // should be amount of jettons to send
     destination: Address; // should be user address / TokenNotification.from
     responseDestination: Address?; // should be myAddress()
     customPayload: Cell?; // should be null
     forwardTonAmount: Int as coins; // should be ton("0.01")
     forwardPayload: Slice as remaining; // should be emptySlice()
}

contract StakingChild with Deployable {
    parent: Address;
    owner: Address;
    stakedBalance: Int as coins;
    rewardBalance: Int as coins;
    stakeTimestamp: Int;
    jettonAddress: Address; // Address of the Jetton contract

    init(parent: Address, owner: Address, jettonAddress: Address) {
        self.parent = parent;
        self.owner = owner;
        self.stakedBalance = 0;
        self.rewardBalance = 0;
        self.stakeTimestamp = 0;
        self.jettonAddress = jettonAddress;
    }




   
 

    receive(msg: ClaimReward) {
        require(sender() == self.owner, "Access denied");
        let rewardAmount: Int = self.calculateReward();
        self.rewardBalance = rewardAmount;
        self.transferRewardToUser(rewardAmount);
    }

    fun calculateReward(): Int {
        let currentTimestamp: Int = now();
        let totalDurationInDays: Int = (currentTimestamp - self.stakeTimestamp) / 86400; // seconds in a day
        let rewardRatePerYear: Int = 10; // Annual reward rate (10%)
        let conversionRate: Int = 100; // Conversion rate (1 TON = 100 reward Jettons)
        
        // Calculate daily reward rate
        let dailyRewardRate: Int = rewardRatePerYear / 365; // Daily reward rate as a percentage
        
        // Calculate the reward amount
        let baseReward: Int = self.stakedBalance * dailyRewardRate / 100;
        let totalReward: Int = baseReward * totalDurationInDays;
        
        // Convert to reward Jettons
        return totalReward * conversionRate;
    }

    fun transferRewardToUser(amount: Int) {
       send(SendParameters{
        to: self.parent,
        value: ton("0.05"),
        body: TransferReward{amount: amount, to: self.owner}.toCell(),
        mode: SendIgnoreErrors
       });

    }


 receive(msg: UpdateStakeDetails) {
        self.stakedBalance = self.stakedBalance + (msg.amount);
        self.stakeTimestamp = now();
    }

    get fun stakedBalance(): Int {
        return self.stakedBalance;
    }

    get fun rewardBalance(): Int {
        self.rewardBalance = self.calculateReward();
        return self.rewardBalance;
    }
}
