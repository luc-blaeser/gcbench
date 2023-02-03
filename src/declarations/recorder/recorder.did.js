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
    'get' : IDL.Func([IDL.Nat], [IDL.Opt(Statistics)], []),
    'record' : IDL.Func([Statistics], [], []),
    'result' : IDL.Func([], [IDL.Text], []),
  });
};
export const init = ({ IDL }) => { return []; };
