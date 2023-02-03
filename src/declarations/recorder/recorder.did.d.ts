import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Statistics {
  'heapSize' : bigint,
  'maxLiveSize' : bigint,
  'allocated' : bigint,
  'collectorInstructions' : bigint,
  'mutatorInstructions' : bigint,
  'reclaimed' : bigint,
  'memorySize' : bigint,
}
export interface _SERVICE {
  'record' : ActorMethod<[Statistics], undefined>,
  'result' : ActorMethod<[], string>,
  'state' : ActorMethod<[], Array<Statistics>>,
}
