import Prim "mo:prim";
import CanCan "dfinity/service/CanCan";
import Trace "../trace";

actor {
    let userCount = 8;
    let chunkCount = 16;

    let pages = 16;
    let blockSize = 65536;
    let headerSize = 8;
    ignore Prim.stableMemoryGrow(Prim.natToNat64(pages));
    let blob = Prim.stableMemoryLoadBlob(0, pages * blockSize - headerSize);
    let chunk = Prim.blobToArray(blob);
    
    func uploadVideo(service: CanCan.CanCan, number: Nat): async () {
        Prim.debugPrint("Upload video " # debug_show(number));
        let userName = "TestUser" # debug_show(number);
        let videoName = "TestVideo" # debug_show(number);
        let profile = await service.createProfile(userName, null);
        checkNonNull(profile);
        let videoInfo = await service.createVideo({
            userId = userName;
            name = videoName;
            createdAt = 1;
            caption = videoName;
            tags = ["Test"];
            chunkCount;
        });
        checkNonNull(videoInfo);
        var chunkNumber = 0;
        while (chunkNumber < chunkCount) {
            Prim.debugPrint("Upload chunk " # debug_show(chunkNumber) # " for video " # debug_show(number));
            let result = await service.putVideoChunk(videoName, chunkNumber, chunk);
            checkNonNull(result);
            chunkNumber += 1
        };
    };

    func checkNonNull(result: ?Any) {
        switch result {
            case null Prim.trap("null result");
            case _ {}
        }
    };

    public shared func run(): async Text {
        Prim.debugPrint("CanCan benchmark");
        Prim.cyclesAdd(2_000_000_000_000); 
        let service = await CanCan.CanCan();
        var userNumber = 0;
        while (userNumber < userCount) {
            await uploadVideo(service, userNumber);
            userNumber += 1
        };
        await Trace.result()
    };
}
