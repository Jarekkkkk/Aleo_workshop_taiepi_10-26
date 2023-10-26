// The 'aleo_workshop_jarek' program.
program aleo_workshop_jarek.aleo {

    mapping balance: address => u64;
    record Token {
        owner: address,
        balance: u64
    }

    transition mint(amount: u64) ->  Token{
        return Token{
            owner: self.caller,
            balance: amount
        };
    }

    // transfer
    transition transfer(receiver: address, amount: u64, input: Token)->(Token, Token){
        let diff: u64 = input.balance - amount;

        let orignal_owner:Token = Token{
            owner: self.caller,
            balance: diff
        };

        let recipient: Token = Token{
            owner: receiver,
            balance: amount
        };

        return (orignal_owner, recipient);
    }

    // transfer[public]
    transition transfer_public(receiver: address, amount: u64){
        return then finalize (self.caller, receiver, amount);
    }

    finalize transfer_public (sender: address,receiver: address, amount: u64) {
        let sender_balance: u64 = Mapping::get(balance, sender);
        let diff: u64 = sender_balance -amount;

        Mapping::set(balance, sender, diff);

        let receiver_amount: u64 = Mapping::get_or_use(balance, receiver, 0u64);
        Mapping::set(balance, receiver, receiver_amount + amount);
    }

    // transfer[private_to_public]
    transition transfer_private_to_public(receiver: address, amount: u64, input: Token)->Token{
        let diff:u64 = input.balance - amount;
        let original_owner:Token = Token{
            owner: self.caller,
            balance: diff
        };
        return then finalize(receiver, amount);
    }

    finalize transfer_private_to_public(receiver: address, amount: u64) {
        let prev_balance: u64 = Mapping::get_or_use(balance, receiver, 0u64);
        Mapping::set(balance, receiver, prev_balance + amount);
    }

    // transfer[public_to_private]
    transition transfer_public_to_private(receiver: address, amount: u64)->Token{
        let original_owner:Token = Token{
            owner: receiver,
            balance: amount
        };
        return original_owner then finalize(self.caller, amount);
    }

    finalize transfer_public_to_private(sender: address, amount: u64) {
        let prev_balance: u64 = Mapping::get_or_use(balance, sender, 0u64);
        Mapping::set(balance, sender, prev_balance - amount);
    }

    transition join (token: Token, token_1: Token) -> Token {
        return Token{
            owner: self.caller,
            balance: token.balance + token_1.balance
        };
    }
}
