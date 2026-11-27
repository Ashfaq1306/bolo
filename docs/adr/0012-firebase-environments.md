# ADR-12: Firebase environments

- **Status:** Accepted (2026-11-27). Corrects the environment table in [docs/04 § 4.6](../04-system-architecture.md#46-environments), which listed `bolo-bd` as production.

## Decision
| Environment | Firebase project | Notes |
|---|---|---|
| Local | Emulator Suite (`demo-bolo` in CI) | No real data |
| **Development** | **`bolo-bd`** | Firestore `asia-south1`; anonymous auth enabled; automatic anonymous cleanup disabled |
| Production | `bolo-prod` | **Deferred** until production preparation (M6) and explicit team approval |

- Cloud Functions deployment and the Blaze plan are **deferred to M6 and need explicit team approval**.
- Nobody deploys rules, functions or config to any project without explicit approval.
- The region (`asia-south1`) is re-checked for availability and price when `bolo-prod` is created.
