# 5. Database schema (Cloud Firestore)

## 5.1 Principles

1. **Everything a user owns lives under `users/{uid}`.** Security rules then only need one ownership check (`request.auth.uid == uid`), and deleting a user means deleting one subtree.
2. **Money is an integer in poisha.** ৳1 = 100 poisha.
3. **Times are Firestore `Timestamp`s (UTC).** They are converted to Asia/Dhaka only for display and scheduling.
4. **Each document has `createdAt` and `updatedAt`** (server timestamps) and `schemaVersion` (int), which makes future migrations possible.
5. **No raw audio, ever. Transcripts are not stored by default.** A `source` field records *how* a record was created (`voice`/`text`/`manual`), not *what* was said.
6. **Small documents, flat fields.** No arrays that grow without bound.

## 5.2 Collections

```
users/{uid}                                  ← profile & settings (owner read/write)
users/{uid}/reminders/{reminderId}
users/{uid}/tasks/{taskId}
users/{uid}/expenses/{expenseId}
users/{uid}/ledger/{entryId}                 ← receivables & payables
usage/{uid}                                  ← AI quota counters (server-only; clients denied)
```

### `users/{uid}`
| Field | Type | Notes |
|---|---|---|
| `locale` | string | `bn` \| `en` |
| `summaryHour` | int | 0–23, default 21; `-1` = off |
| `storeTranscripts` | bool | default `false` |
| `createdAt`, `updatedAt` | timestamp | |
| `schemaVersion` | int | `1` |

### `users/{uid}/reminders/{id}`
| Field | Type | Required | Notes |
|---|---|---|---|
| `title` | string (1–200) | ✅ | |
| `remindAt` | timestamp | ✅ | UTC instant |
| `repeat` | string | ✅ | `none` \| `daily` \| `weekly` |
| `status` | string | ✅ | `pending` \| `done` \| `cancelled` |
| `notificationId` | int | ✅ | 31-bit int derived from the doc id; used to cancel the notification |
| `source` | string | ✅ | `voice` \| `text` \| `manual` |
| `transcript` | string (≤ 500) | | only if `storeTranscripts` |
| `createdAt`, `updatedAt` | timestamp | ✅ | |
| `schemaVersion` | int | ✅ | |

### `users/{uid}/tasks/{id}`
| Field | Type | Required | Notes |
|---|---|---|---|
| `title` | string (1–200) | ✅ | |
| `dueAt` | timestamp \| null | | a deadline if set |
| `remindAt` | timestamp \| null | | |
| `notificationId` | int | ✅ | |
| `priority` | string | ✅ | `normal` \| `high` |
| `status` | string | ✅ | `open` \| `done` |
| `completedAt` | timestamp \| null | | |
| `source`, `createdAt`, `updatedAt`, `schemaVersion` | | ✅ | |

### `users/{uid}/expenses/{id}`
| Field | Type | Required | Notes |
|---|---|---|---|
| `amountPoisha` | int (1 … 10¹¹) | ✅ | |
| `currency` | string | ✅ | `BDT` |
| `category` | string | ✅ | one of the fixed categories |
| `note` | string (≤ 200) | | |
| `spentAt` | timestamp | ✅ | |
| `source`, `createdAt`, `updatedAt`, `schemaVersion` | | ✅ | |

### `users/{uid}/ledger/{id}`
| Field | Type | Required | Notes |
|---|---|---|---|
| `direction` | string | ✅ | `receivable` (they owe me) \| `payable` (I owe them) |
| `person` | string (1–80) | ✅ | free text; a contacts link is post-MVP |
| `amountPoisha` | int | ✅ | |
| `currency` | string | ✅ | `BDT` |
| `dueAt` | timestamp \| null | | |
| `status` | string | ✅ | `open` \| `settled` |
| `settledAt` | timestamp \| null | | |
| `note` | string (≤ 200) | | |
| `source`, `createdAt`, `updatedAt`, `schemaVersion` | | ✅ | |

### `usage/{uid}` (written only by Cloud Functions with the Admin SDK)
| Field | Type | Notes |
|---|---|---|
| `day` | string | `YYYY-MM-DD` in Asia/Dhaka |
| `count` | int | AI calls made that day |
| `month` | string | `YYYY-MM` |
| `monthCount` | int | |
| `updatedAt` | timestamp | |

It lives outside `users/{uid}` on purpose, so the client cannot reset its own quota: the rules deny all client reads and writes here.

## 5.3 Queries and indexes

The MVP keeps every query **index-free**: screens filter with a single equality (`status == 'open'`) or a single range on one field, and sort on the device. That means no composite indexes to deploy or forget, and each query only returns open/current items (small).

| Screen | Query | Index |
|---|---|---|
| Reminders | `reminders where status == 'pending'` (sorted on device by `remindAt`) | automatic |
| Tasks | `tasks where status == 'open'` (sorted on device by `dueAt`) | automatic |
| Expenses: month | `expenses where spentAt >= monthStart orderBy spentAt desc` | automatic (single field) |
| Ledger | `ledger where status == 'open'` (sorted on device by person) | automatic |

When lists grow (e.g. a "done" history), add `orderBy` + `limit` and the composite index it asks for in `firestore.indexes.json`.

## 5.4 On-device storage (not Firestore)

> **Since Phase 1 (2026-11-27, [ADR-10](adr/0010-drift-local-first.md), [ADR-11](adr/0011-guest-data-local-only.md)):** personal records and the inbox live in a local Drift/SQLite database (`bolo.sqlite`, § 5.7). Guests never write to Firestore. Accounts registered before Phase 2 still read and write Firestore until registered sync ships.

| Data | Store | Why |
|---|---|---|
| Reminders, tasks, expenses, ledger, inbox | Drift (`app/lib/data/bolo_database.dart`) | source of truth on the phone, works offline from first launch |
| Firestore cache | Firestore SDK | read by the one-time guest migration; used by pre-Phase-2 registered accounts |
| UI settings (language, voice, summary time) | `shared_preferences` | not personal records |
| Old inbox (`inbox.v1`) | `shared_preferences` | copied once into Drift; left in place, no longer used |

## 5.5 Estimated size

A record is about 300–500 bytes. A heavy user with 20 records/day for a year produces about 7,300 docs, or around 3.5 MB. That is far below Firestore's free tier for the first thousands of users. Reads are the cost to watch, not storage; see [09](09-cost-control.md).

## 5.6 Migration strategy

> The one-time move of existing Firestore records into Drift is designed in [docs/13 § 11](13-phase0-guest-data-audit.md#11-guest-migration-six-scenarios) (journaled, idempotent, never deletes the source).

`schemaVersion` on every document means the app can read v1 and v2 side by side during a migration. Changes should only add fields; renaming or deleting fields requires a one-off migration function.

## 5.7 Local database (Drift), schema version 1

File: `app/lib/data/bolo_database.dart`. Code generation: `dart run build_runner build` (the generated `bolo_database.g.dart` is committed). Times are UTC milliseconds in integer columns; money is integer minor units plus `currency`.

**Columns on every record table** (`reminders`, `tasks`, `expenses`, `ledger_entries`):

| Column | Meaning |
|---|---|
| `id` (PK) | stable text id; migrated records keep their Firestore document id |
| `owner_scope` | `device:<deviceId>` (guest) or `account:<uid>` (registered, Phase 2) |
| `created_at`, `updated_at` | UTC ms |
| `deleted_at` | tombstone; deletes never remove the row |
| `rev` | +1 on every local change |
| `last_device_id` | device that made the last change |
| `sync_state` | `local` (guest, never syncs), `pending`, `synced`, `conflict` |
| `server_updated_at` | Firestore `updatedAt` of the copy last reconciled with |
| `origin` | `local`, `migrated`, `imported` |
| `schema_version` | record schema version |

**Per table:** `reminders` (title, remind_at, repeat, status, source, time_zone), `tasks` (title, due_at, remind_at, priority, status, completed_at, source, time_zone), `expenses` (amount_minor, currency, category, note, spent_at, source), `ledger_entries` (direction, person, amount_minor, currency, due_at, status, settled_at, note, source).

**Other tables:** `inbox_items` (local only, max 20 per owner), `app_meta` (key/value: `device_id`, `legacy_anon_uid`, `legacy_checked`, `inbox_imported`), `migration_runs` and `migration_items` (the guest-migration journal: states, counts, ids and checksums only, never record content).

**Indexes:** `(owner_scope, deleted_at, status)` on reminders, tasks and ledger; `(owner_scope, remind_at)`; `(owner_scope, spent_at)`; `(sync_state)` on every record table.

**Not yet (Phase 2):** `sync_outbox`, `sync_state` cursors, `ledger_payments`. Each schema change raises `schemaVersion`, adds a step in `MigrationStrategy.onUpgrade` and a test.

