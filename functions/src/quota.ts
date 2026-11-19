import type { Firestore } from "firebase-admin/firestore";
import { FieldValue } from "firebase-admin/firestore";

import { dhakaDate } from "./parse/calendar";

export const DAILY_LIMIT = 40;
export const MONTHLY_LIMIT = 600;

export interface QuotaState {
  day: string;
  count: number;
  month: string;
  monthCount: number;
}

/** Pure decision logic (unit-tested without Firestore). */
export function nextQuota(prev: Partial<QuotaState> | undefined, now: Date): { allowed: boolean; next: QuotaState } {
  const day = dhakaDate(now);
  const month = day.slice(0, 7);
  const count = prev?.day === day ? prev.count ?? 0 : 0;
  const monthCount = prev?.month === month ? prev.monthCount ?? 0 : 0;
  const allowed = count < DAILY_LIMIT && monthCount < MONTHLY_LIMIT;
  return {
    allowed,
    next: allowed
      ? { day, count: count + 1, month, monthCount: monthCount + 1 }
      : { day, count, month, monthCount },
  };
}

/**
 * Atomically counts one AI call for this user. Runs BEFORE the AI call so a
 * user (or a bot) cannot exceed the limit. `usage/{uid}` is not readable or
 * writable by clients (see firestore.rules), so the app cannot reset it.
 */
export async function consumeQuota(db: Firestore, uid: string, now: Date): Promise<boolean> {
  const ref = db.collection("usage").doc(uid);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const { allowed, next } = nextQuota(snap.data() as Partial<QuotaState> | undefined, now);
    if (allowed) tx.set(ref, { ...next, updatedAt: FieldValue.serverTimestamp() });
    return allowed;
  });
}
