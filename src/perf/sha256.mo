import SHA256 "./sha256/SHA256";
import Array "./sha256/Array";
import Nat8 "./sha256/Nat8";

module {
  public func go() {
    // reduced to 64kb as it otherwise exceeds the instruction limit
    ignore SHA256.sha256(Array.tabulate(64*1024, Nat8.fromIntWrap));
  }
}
//CALL ingress go 0x4449444C0000
