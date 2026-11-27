# ADR-10: Drift/SQLite local-first storage, explicit Firestore sync for registered users

- **Status:** Accepted (2026-11-27). **Supersedes ADR-5** ("Firestore offline persistence as the local DB").
- **Implementation:** not started. Planned for Phase 1 (storage) and Phase 2 (sync), see [docs/10](../10-milestones.md).

## Context
ADR-5 used Firestore's offline cache as the app's only database. That made every
record, including guest records, a Firestore document owned by a Firebase uid.
The Phase 0 audit ([docs/13](../13-phase0-guest-data-audit.md)) confirmed the consequences:
- the app cannot start or save anything offline on first launch (no uid yet);
- guest data cannot be local-only;
- losing the anonymous identity makes all earlier records unreachable;
- rejected writes are silently rolled back from the cache.

## Decision
1. **Drift (SQLite) is the source of truth on the phone** for all personal records.
2. **Firestore holds cloud copies only for registered accounts**, synchronised by
   app-owned code (outbox + pull cursor), not by treating the cache as the database.
3. Screens keep using the `RecordsRepository` interface; a `DriftRecordsRepository`
   replaces `FirestoreRecordsRepository`. Domain models stop importing Firestore types.
4. Every record gets: stable text `id` (existing Firestore ids are kept), `owner_scope`,
   `created_at`/`updated_at` (UTC ms), `deleted_at` (tombstone), `rev`, `last_device_id`,
   `sync_state`, `server_updated_at`, `origin`, `schema_version`; money stays integer
   minor units with a `currency` column; reminders store an IANA time zone.
5. Sync runs **without Cloud Functions** (Firestore SDK from the app), so it does not
   pull the deferred M6 billing work forward.

## Consequences
- More code than ADR-5 (sync, conflicts, tombstones), accepted for correctness of guest data.
- Requires a one-time, journaled migration of existing Firestore records (docs/13 § 11).
- Firestore rules must later accept the sync fields and soft deletes.
