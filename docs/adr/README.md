# Architecture decision records (ADRs)

One file per decision. A decision is **never rewritten**: when it changes, a new
ADR is added with status `Accepted` and the old one is marked `Superseded by ADR-N`.
ADR-1 to ADR-9 live in the summary table in [docs/04 § 4.7](../04-system-architecture.md#47-key-architectural-decisions-adr-summary).

| ADR | Title | Status |
|---|---|---|
| [ADR-10](0010-drift-local-first.md) | Drift/SQLite local-first storage with explicit Firestore sync for registered users | Accepted (supersedes ADR-5) |
| [ADR-11](0011-guest-data-local-only.md) | Guest data is local-only; anonymous auth is not a data owner | Accepted (supersedes the data-ownership part of ADR-7) |
| [ADR-12](0012-firebase-environments.md) | `bolo-bd` is development; production `bolo-prod` is deferred | Accepted (corrects docs/04 § 4.6) |

Background and the full audit: [docs/13 Phase 0 audit](../13-phase0-guest-data-audit.md).
