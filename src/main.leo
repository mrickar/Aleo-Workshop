// The 'meric_workshop' program.
program meric_workshop.aleo {
    mapping account:address => u64;
    record token {
        owner: address,
        amount: u64,
    }

    transition mint_public (public receiver:address,public amount:u64) { 
        
        return then finalize(receiver,amount);
    }

    finalize mint_public (public receiver:address,public amount:u64) {
        
        let receiver_amount:u64 = Mapping::get_or_use(account,receiver ,0u64 );
        Mapping::set(account,receiver ,amount+receiver_amount);
    }

    transition  mint_private(private receiver:address,private amount:u64) -> token{
        
        return token{
            owner:receiver,
            amount:amount
        };
    }

    transition transfer_public (public receiver:address,public amount:u64)  {
        return then finalize(self.caller,receiver,amount);
    }

    finalize transfer_public (public sender:address,public receiver:address,public amount:u64) {

        let sender_amount:u64 = Mapping::get_or_use(account,sender,0u64);
        Mapping::set(account,sender ,sender_amount-amount);
        let receiver_amount:u64 = Mapping::get_or_use(account,receiver ,0u64 );
        Mapping::set(account,receiver,amount+sender_amount);
    }

    transition transfer_private (private sender:token,private receiver:address,private amount:u64) ->(token,token)  {
        
        let difference:u64 = sender.amount - amount;
        let remaining:token = token {
            owner:sender.owner,
            amount:difference
        };
        let transferred:token = token {
            owner:receiver,
            amount:amount
        };
        return (remaining,transferred);
    }

    transition transer_private_to_public (private sender:token,public receiver:address,public amount:u64) -> token {

        let difference:u64 = sender.amount - amount;
        let remaining:token = token {
            owner:sender.owner,
            amount:difference
        };
        return remaining then finalize(receiver,amount);
    }

    finalize transer_private_to_public (public receiver:address,public amount:u64) {

        let receiver_amount:u64 = Mapping::get_or_use(account,receiver ,0u64 );
        Mapping::set(account,receiver,amount+receiver_amount);
    }

    transition transer_public_to_private (private receiver:address,public amount:u64) -> token {

        let transferred:token = token {
            owner:receiver,
            amount:amount
        };
        return transferred then finalize(self.caller,amount);
    }
    
    finalize transer_public_to_private (public sender:address,public amount:u64) {

        let sender_amount:u64 = Mapping::get_or_use(account,sender ,0u64 );
        Mapping::set(account,sender,sender_amount-amount);
    }
}
