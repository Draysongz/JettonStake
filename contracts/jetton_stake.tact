import "@stdlib/deploy";
import "../contracts/staking_child.tact";

struct Metadata {
    symbol: String;
    totalStaked: Int;
}

message CreateAggregtor{
    owner: Address;
}

message ChangeAdmin {
    newOwner: Address;
}


contract JettonStake with Deployable {
    symbol: String;
    totalStaked: Int as coins;
    rewardTokenAddress: Address; // Address of the reward token contract
    rewardTokenBalance: Int as coins;
    owner: Address;
    arrLength: Int as uint8 = 0;
    arrStart: Int as uint8 = 0;
    stakeTimestamp: Int;
    arr: map<Address, Int>;
    const MinTonForStorage: Int = ton("0.01");

    
    init(rewardToken: Address) {
        self.symbol = "TON";
        self.totalStaked= 0;
        self.rewardTokenAddress= rewardToken;
        self.rewardTokenBalance = 0;
        self.owner = sender();
        self.stakeTimestamp = 0;
    }


    //function for child contract
    fun createStakingChild(to: Address): Address {
        let init: StateInit = initOf StakingChild(myAddress(), to, self.rewardTokenAddress);
        self.arrPush(to, 0);
        send(SendParameters{
            to: contractAddress(init),
            value: ton("0.03"),
            mode: SendIgnoreErrors,
            code: init.code,
            data: init.data
        });

        return contractAddress(initOf StakingChild(myAddress(), to, self.rewardTokenAddress));
    }


    //message for creating child contract
    receive (msg: CreateAggregtor){
        self.createStakingChild(msg.owner);   
    }



// Message for claiming rewards
    receive(msg: TransferReward) {
        require(msg.amount <= self.rewardTokenBalance, "Insufficient reward balance");
         self.sendJettonTransfer(msg.to, msg.amount);
        self.rewardTokenBalance = self.rewardTokenBalance - msg.amount;     
    }



// function for pushing child contract and staked balance intot eh array of maps
        fun arrPush(address: Address, balance: Int){
        dump("in array psuh creating account...");
        self.arr.set(address, balance);
        dump("done creating account, updating array length");
        self.arrLength = self.arrLength + 1;
        dump("done updating array length");
    }
    
    
    //function for checking if an address is the array of maps
    fun check(owner: Address): Bool{
      let found: Bool = false;
      let arr: map<Address, Int> = self.arr;

        // Iterating over the map in contract storage
        foreach (key, value in arr) {
            if (key == owner) {
                dump(key); 
                found = true;
            } else {
                  dump("Address not found: " );
                  found = false;
            }
        }

        return found;

    }


     fun sendJettonTransfer(to: Address, amount: Int) {
        // Send a message to the Jetton contract to perform the transfer
        send(SendParameters{
            to: self.rewardTokenAddress,
            body: TokenTransfer{
                queryId: 0, // should be 0
     amount: amount, // should be amount of jettons to send
     destination: to, // should be user address / TokenNotification.from
     responseDestination: myAddress(), // should be myAddress()
     customPayload: null, // should be null
     forwardTonAmount: ton("0.01"), // should be ton("0.01")
     forwardPayload: emptySlice() // should be emptySlice()
            }.toCell(),
            value: ton("0.03"), // Fee to cover the transaction
            mode: SendIgnoreErrors
        });
    }



   
//getter function for getting staked token details and totalstaked
    get fun metadata(): Metadata {
        return Metadata{symbol: self.symbol, totalStaked: self.totalStaked};
    }

//getter function for getting child contract address for a particular user
    get fun childAddress(owner: Address): Address {
        return contractAddress(initOf StakingChild(myAddress(), owner, self.rewardTokenAddress));
    }


//message for staking
  receive(msg: Stake){
        let amount: Int = msg.amount;
        let owner: Address = sender();
        let existing : Bool = self.check(owner);
        if(existing){
             dump("exisiting details found");
            let existingBalance: Int = self.arr.get(owner)!!;
            let newBalance: Int = existingBalance + amount;
            self.arr.set(owner, newBalance);
            let Init: StateInit= initOf StakingChild(myAddress(), owner, self.rewardTokenAddress);
            send(SendParameters{
                     to: contractAddress(Init),
                     body: UpdateStakeDetails{amount: msg.amount}.toCell(),
                     value: ton("0.01"),
                     mode: SendIgnoreErrors
                });

        } else {
            dump("creating new stake account....");
            self.arrPush(owner, amount);
        }
    }



    receive(msg: ChangeAdmin){
        require(sender() == self.owner, "You're not authorized to perform this operation");
        self.owner = msg.newOwner;
        dump(self.owner);
    }


 receive("withdraw all") {
        require(sender() == self.owner, "Only owner is allowed to withdraw");
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: myBalance() - context().value - self.MinTonForStorage,
            mode: SendRemainingValue + SendIgnoreErrors
        });
    }

}
