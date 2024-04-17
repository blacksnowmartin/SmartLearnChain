import FungibleToken from "../common/FungibleToken.mo";

actor Main {
  var userLedger: FungibleToken.Ledger;
  var universityLedger: FungibleToken.Ledger;

  public func init() {
    userLedger = FungibleToken.makeLedger();
    universityLedger = FungibleToken.makeLedger();
  }

  public shared({ caller }) func payFees() {
    // Ensure caller has sufficient balance in user ledger
    if (userLedger.balance(caller) < 30) {
      throw InsufficientFunds();
    } else {
      // Deduct 30 tokens from caller's balance in user ledger
      let success = userLedger.withdraw(caller, 30);
      if (success) {
        // Transfer 30 tokens to university ledger
        universityLedger.deposit(Principal.fromActor(Main), 30); // Deposit to self
      } else {
        throw InsufficientFunds();
      }


    // Deduct 30 tokens from caller's balance in user ledger
    userLedger.withdraw(caller, 30);

    // Transfer 30 tokens to university ledger
    universityLedger.deposit(Principal.fromActor(Main), 30); // Deposit to self
  }

  public query func getBalance() : async Nat {
    return universityLedger.balance(Principal.fromActor(Main));
  }
}
