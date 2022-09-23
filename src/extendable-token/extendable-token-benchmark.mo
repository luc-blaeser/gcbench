import Prim "mo:prim";
import Principal "mo:base/Principal";
import ExtStandard "toniq-labs-code/examples/standard";
import Trace "../trace";

actor {
    private var standard: ?ExtStandard.standard_token = null;

    private let initialAmount = 10_000;

    public shared(msg) func initialize(): async () {
        let owner = msg.caller;
        Prim.cyclesAdd(200_000_000_000);    
        standard := ?(await ExtStandard.standard_token("Me Token", "MET", 3, initialAmount, owner));
        await Trace.point()
    };

    private let receiver = "012345678901234567890123456789012345678901234567890123456789abcd";

    private var senderBalance = initialAmount;
    private var receiverBalance = 0;

    public shared(msg) func transfer(): async () {
        let amount = 100;
        let sender = msg.caller;
        switch (standard) {
            case (?platform) {
                let token = Principal.toText(Principal.fromActor(platform));
                let response = await platform.transfer({
                    from = #principal sender;
                    to = #address receiver;
                    token;
                    amount;
                    memo = Prim.arrayToBlob([]);
                    notify = false;
                    subaccount = null
                });
                switch (response) {
                    case (#ok _) {};
                    case (_) Prim.trap("Transaction failed")
                };
                senderBalance -= amount;
                receiverBalance += amount;
                let actualSenderBalance = await platform.balance({ 
                    user = #principal sender;
                    token
                });
                assert(#ok senderBalance == actualSenderBalance);
                let actualReceiverBalance = await platform.balance({
                    user = #address receiver;
                    token
                });
                await Trace.point();
                assert(#ok receiverBalance == actualReceiverBalance)
            };
            case _ Prim.trap("No platform")
        }
    };

    public shared(msg) func run(): async Text {
        await initialize();
        var count = 0;
        while (count < 100) {
            await transfer();
            count += 1
        };
        await Trace.result()
    }
}
