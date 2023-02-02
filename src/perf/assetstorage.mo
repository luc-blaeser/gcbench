import Error "assetstorage/Error";
import Tree "assetstorage/RBTree";
import Text "assetstorage/Text";
import Iter "assetstorage/Iter";

shared({caller = creator}) actor class AssetStorage () {

    public type Path = Text;
    public type Contents = Blob;

    let initializer : Principal = creator;

    let db: Tree.RBTree<Path, Contents> = Tree.RBTree(Text.compare);

    public shared({caller}) func store(path : Path, contents : Contents) : async () {
        if (caller != initializer) {
            throw Error.reject("not authorized");
        } else {
            db.put(path, contents);
        };
    };

    public /*query*/ func retrieve(path : Path) : async Contents {
        switch (db.get(path)) {
        case null throw Error.reject("not found");
        case (?contents) contents;
        };
    };

    public /*query*/ func list() : async [Path] {
        let iter = Iter.map<(Path, Contents), Path>(db.entries(), func (path, _) = path);
        Iter.toArray(iter);
    };
};

//CALL query list 0x4449444C0000
//CALL ingress store 0x4449444C016d7b02710004414243440400010203
//CALL query list 0x4449444C0000
//CALL query retrieve 0x4449444C0001710441424344

