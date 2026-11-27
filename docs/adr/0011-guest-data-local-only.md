# ADR-11: Guest data is local-only; anonymous auth is not a data owner

- **Status:** Accepted (2026-11-27). **Supersedes the data-ownership part of ADR-7**
  (ADR-7's zero-friction start is kept).
- **Implementation:** not started (Phase 1–3, see [docs/10](../10-milestones.md)).

## Decision
1. Three separate identities:
   - **Device identity:** a `deviceId` created on the phone at first launch (no network). Owns the guest workspace (`owner_scope = device:<deviceId>`).
   - **Session identity:** Firebase Auth. Optional. An anonymous session may be used only as a token for AI quota, **never** to access personal records.
   - **Account identity:** a registered uid (email now; Google, Apple later). The only owner of cloud data (`owner_scope = account:<uid>`).
2. Guest records live **only in the local Drift database**. They are never deleted,
   overwritten or discarded because of an authentication change. There is no automatic
   guest-data deletion; a guest can explicitly delete all data on this device.
3. Signing in to an existing account never mixes data silently: the user chooses
   to keep guest data on this device, import it into the account, or leave it separate.
4. Firestore rules will deny anonymous users access to personal records. To protect
   existing users, this happens in two steps after the migration ships:
   anonymous **read-only** (grace period), then no access. Automatic anonymous
   account cleanup stays disabled.

## Consequences
- First launch works fully offline.
- Existing guest records in Firestore must be migrated (docs/13 § 11) **before** rules
  change and **before** any "sign in to existing account" screen exists.
- Guest data has no cloud backup; the backup policy is an open founder decision (docs/11).
