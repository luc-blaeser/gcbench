export const idlFactory = ({ IDL }) => {
  const Statistics = IDL.Record({
    'heapSize' : IDL.Nat,
    'maxLiveSize' : IDL.Nat,
    'allocated' : IDL.Nat,
    'collectorInstructions' : IDL.Nat,
    'mutatorInstructions' : IDL.Nat,
    'reclaimed' : IDL.Nat,
    'memorySize' : IDL.Nat,
  });
  return IDL.Service({
    'record' : IDL.Func([Statistics], [], []),
    'result' : IDL.Func([], [IDL.Text], []),
    'state' : IDL.Func([], [IDL.Vec(Statistics)], []),
  });
};
export const init = ({ IDL }) => { return []; };
