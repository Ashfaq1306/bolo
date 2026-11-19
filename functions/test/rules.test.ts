/**
 * Security-rules tests. Run against the Firestore emulator:
 *   cd functions && npx firebase emulators:exec --only firestore "npm run test:rules"
 */
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { doc, getDoc, serverTimestamp, setDoc, Timestamp, updateDoc } from "firebase/firestore";
import { afterAll, beforeAll, beforeEach, describe, it } from "vitest";

let env: RulesTestEnvironment;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-bolo",
    firestore: { rules: readFileSync(resolve(__dirname, "../../firestore.rules"), "utf8") },
  });
});
afterAll(async () => env?.cleanup());
beforeEach(async () => env.clearFirestore());

const expense = (extra: Record<string, unknown> = {}) => ({
  amountPoisha: 35000,
  currency: "BDT",
  category: "food",
  note: "lunch",
  spentAt: Timestamp.now(),
  source: "voice",
  schemaVersion: 1,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  ...extra,
});

describe("per-user isolation", () => {
  it("owner can create and read their expense", async () => {
    const db = env.authenticatedContext("alice").firestore();
    await assertSucceeds(setDoc(doc(db, "users/alice/expenses/e1"), expense()));
    await assertSucceeds(getDoc(doc(db, "users/alice/expenses/e1")));
  });

  it("another user cannot read or write it", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "users/alice/expenses/e1"), { amountPoisha: 1 });
    });
    const bob = env.authenticatedContext("bob").firestore();
    await assertFails(getDoc(doc(bob, "users/alice/expenses/e1")));
    await assertFails(setDoc(doc(bob, "users/alice/expenses/e2"), expense()));
  });

  it("signed-out users get nothing", async () => {
    const anon = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(anon, "users/alice/expenses/e1")));
  });
});

describe("validation", () => {
  const alice = () => env.authenticatedContext("alice").firestore();

  it("rejects float money", async () => {
    await assertFails(setDoc(doc(alice(), "users/alice/expenses/e1"), expense({ amountPoisha: 350.5 })));
  });

  it("rejects negative or huge money", async () => {
    await assertFails(setDoc(doc(alice(), "users/alice/expenses/e1"), expense({ amountPoisha: -100 })));
    await assertFails(setDoc(doc(alice(), "users/alice/expenses/e1"), expense({ amountPoisha: 1e12 })));
  });

  it("rejects unknown fields and categories", async () => {
    await assertFails(setDoc(doc(alice(), "users/alice/expenses/e1"), expense({ isAdmin: true })));
    await assertFails(setDoc(doc(alice(), "users/alice/expenses/e1"), expense({ category: "crypto" })));
  });

  it("rejects client-chosen timestamps for createdAt", async () => {
    await assertFails(setDoc(doc(alice(), "users/alice/expenses/e1"), expense({ createdAt: Timestamp.now() })));
  });

  it("allows a status-only update on a ledger entry", async () => {
    const db = alice();
    await assertSucceeds(
      setDoc(doc(db, "users/alice/ledger/l1"), {
        direction: "receivable",
        person: "Karim",
        amountPoisha: 200000,
        currency: "BDT",
        dueAt: null,
        status: "open",
        settledAt: null,
        note: "",
        source: "manual",
        schemaVersion: 1,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      }),
    );
    await assertSucceeds(
      updateDoc(doc(db, "users/alice/ledger/l1"), { status: "settled", settledAt: serverTimestamp(), updatedAt: serverTimestamp() }),
    );
    // ...but not tampering with createdAt.
    await assertFails(updateDoc(doc(db, "users/alice/ledger/l1"), { createdAt: Timestamp.now(), updatedAt: serverTimestamp() }));
  });

  it("reminders need a title and valid enums", async () => {
    const base = {
      title: "rent",
      remindAt: Timestamp.now(),
      repeat: "none",
      status: "pending",
      notificationId: 42,
      source: "voice",
      schemaVersion: 1,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    };
    await assertSucceeds(setDoc(doc(alice(), "users/alice/reminders/r1"), base));
    await assertFails(setDoc(doc(alice(), "users/alice/reminders/r2"), { ...base, title: "" }));
    await assertFails(setDoc(doc(alice(), "users/alice/reminders/r3"), { ...base, repeat: "hourly" }));
  });
});

describe("quota counters are server-only", () => {
  it("client cannot read or reset usage", async () => {
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(getDoc(doc(db, "usage/alice")));
    await assertFails(setDoc(doc(db, "usage/alice"), { count: 0 }));
  });
});
