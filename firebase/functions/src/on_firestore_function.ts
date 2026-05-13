import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export enum FirestoreEventType {
  onCreate = 'onCreate',
  onUpdate = 'onUpdate',
  onWrite = 'onWrite',
  onDelete = 'onDelete',
}

export interface AppFirestoreFunctionData {
  functionName: string;
  firestoreEventType: FirestoreEventType;
}

export interface RuntimeOptions {
  timeoutSeconds?: number;
  memory?: string;
  minInstances?: number;
}

type DocumentSnapshot = admin.firestore.DocumentSnapshot;
type Change<T> = functions.Change<T>;
type EventContext = functions.EventContext;

/**
 * Abstract base class for Firestore-triggered Cloud Functions.
 * Corresponds to Dart's OnFirestoreFunction<T>.
 */
export abstract class OnFirestoreFunction<T> {
  readonly appFirestoreFunctionData: AppFirestoreFunctionData[];
  readonly documentFromJson: (snapshot: DocumentSnapshot) => T;
  readonly runWithOptions?: RuntimeOptions;

  abstract get documentPath(): string;

  constructor(
    appFirestoreFunctionData: AppFirestoreFunctionData[],
    documentFromJson: (snapshot: DocumentSnapshot) => T,
    opts?: { runWithOptions?: RuntimeOptions }
  ) {
    this.appFirestoreFunctionData = appFirestoreFunctionData;
    this.documentFromJson = documentFromJson;
    this.runWithOptions = opts?.runWithOptions;
  }

  async onCreate(
    _snapshot: DocumentSnapshot,
    _parsedData: T,
    _updateTime: Date,
    _context: EventContext
  ): Promise<void> {
    throw new Error('Not implemented');
  }

  async onUpdate(
    _changes: Change<DocumentSnapshot>,
    _before: T,
    _after: T,
    _updateTime: Date,
    _context: EventContext
  ): Promise<void> {
    throw new Error('Not implemented');
  }

  async onWrite(
    _changes: Change<DocumentSnapshot>,
    _before: T,
    _after: T,
    _updateTime: Date,
    _context: EventContext
  ): Promise<void> {
    throw new Error('Not implemented');
  }

  async onDelete(
    _snapshot: DocumentSnapshot,
    _parsedData: T,
    _updateTime: Date,
    _context: EventContext
  ): Promise<void> {
    throw new Error('Not implemented');
  }

  async firestoreOnCreate(
    functionName: string,
    data: DocumentSnapshot,
    context: EventContext
  ): Promise<void> {
    try {
      const parsedData = this.documentFromJson(data);
      return await this.onCreate(data, parsedData, context.timestamp ? new Date(context.timestamp) : new Date(), context);
    } catch (e) {
      console.error(`Error during action ${functionName}`, e);
      throw e;
    }
  }

  async firestoreOnUpdate(
    functionName: string,
    changes: Change<DocumentSnapshot>,
    context: EventContext
  ): Promise<void> {
    console.log('starting firestore action for update');
    try {
      const after = this.documentFromJson(changes.after);
      const before = this.documentFromJson(changes.before);
      return await this.onUpdate(changes, before, after, context.timestamp ? new Date(context.timestamp) : new Date(), context);
    } catch (e) {
      console.error(`Error during action ${functionName}`, e);
      throw e;
    }
  }

  async firestoreOnWrite(
    functionName: string,
    changes: Change<DocumentSnapshot>,
    context: EventContext
  ): Promise<void> {
    try {
      const after = this.documentFromJson(changes.after);
      const before = this.documentFromJson(changes.before);
      return await this.onWrite(changes, before, after, context.timestamp ? new Date(context.timestamp) : new Date(), context);
    } catch (e) {
      console.error(`Error during action ${functionName}`, e);
      throw e;
    }
  }

  async firestoreOnDelete(
    functionName: string,
    data: DocumentSnapshot,
    context: EventContext
  ): Promise<void> {
    try {
      const parsedData = this.documentFromJson(data);
      return await this.onDelete(data, parsedData, context.timestamp ? new Date(context.timestamp) : new Date(), context);
    } catch (e) {
      console.error(`Error during action ${functionName}`, e);
      throw e;
    }
  }

  register(): Record<string, functions.CloudFunction<unknown>> {
    const opts = this.runWithOptions ?? { timeoutSeconds: 60, memory: '1GB', minInstances: 0 };
    const result: Record<string, functions.CloudFunction<unknown>> = {};

    for (const entry of this.appFirestoreFunctionData) {
      const builder = functions
        .runWith(opts as functions.RuntimeOptions)
        .firestore.document(this.documentPath);

      switch (entry.firestoreEventType) {
        case FirestoreEventType.onCreate:
          result[entry.functionName] = builder.onCreate((snap, ctx) =>
            this.firestoreOnCreate(entry.functionName, snap, ctx)
          );
          break;
        case FirestoreEventType.onUpdate:
          result[entry.functionName] = builder.onUpdate((change, ctx) =>
            this.firestoreOnUpdate(entry.functionName, change, ctx)
          );
          break;
        case FirestoreEventType.onWrite:
          result[entry.functionName] = builder.onWrite((change, ctx) =>
            this.firestoreOnWrite(entry.functionName, change, ctx)
          );
          break;
        case FirestoreEventType.onDelete:
          result[entry.functionName] = builder.onDelete((snap, ctx) =>
            this.firestoreOnDelete(entry.functionName, snap, ctx)
          );
          break;
      }
    }

    return result;
  }
}
