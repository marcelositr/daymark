# Security Policy

## Supported versions

Daymark is pre-release software. Until the first public release, security fixes apply to the current development line only.

## Reporting a vulnerability

Please do not disclose exploitable vulnerabilities in a public issue before a fix is available.

If private vulnerability reporting is enabled for this repository, use GitHub's private vulnerability reporting flow. Otherwise, contact the maintainer privately through the contact information associated with the repository owner.

## Dependency policy

Daymark must not knowingly introduce a dependency with an unresolved known vulnerability unless there is no reasonable alternative and the exception is explicitly documented.

Security exceptions must record:

- the advisory identifier;
- why the dependency cannot currently be removed or upgraded;
- the practical exposure in Daymark;
- the upstream tracking reference;
- a review condition or removal plan.

Permanent blanket ignores are not acceptable.

## Supply-chain policy

- Lockfiles are versioned.
- Dependency updates are reviewed through pull requests.
- GitHub Actions should be pinned to immutable commit SHAs when introduced.
- CI must include static analysis and tests once the application scaffold exists.
- Secrets must never be committed to the repository.
- Production code must not rely on dependencies fetched from mutable Git branches.

## Data model

Daymark is local-first. Core journal data must not be transmitted to remote services as part of normal operation.

Any future network feature must be optional, explicit, documented, and isolated from the core local workflow.
