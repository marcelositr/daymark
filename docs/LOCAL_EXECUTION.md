# Local execution contract

This document defines how AI-provided terminal blocks must behave when the user acts as Daymark's local execution bridge.

The goal is simple: the user should be able to paste one block, let it run without touching the keyboard again, and return the resulting terminal output for diagnosis or validation.

## Non-interactive by default

Every pasteable local validation or diagnostic block must be non-interactive whenever technically possible.

In particular, a block must not unexpectedly:

- open a pager such as `less` and wait for `q`;
- open an editor;
- ask for confirmation;
- wait for menu selection or other keyboard input;
- invoke an interactive credential prompt;
- leave the shell inside a subprocess after the block is complete.

For Git-heavy blocks, prefer explicit non-interactive safeguards such as:

```bash
export CI=true
export PAGER=cat
export GIT_PAGER=cat
export GIT_EDITOR=true
export GIT_TERMINAL_PROMPT=0
```

Use `git --no-pager ...` for commands that can otherwise select a pager. Avoid commands whose normal behavior requires an interactive editor or prompt unless that interaction is the explicit subject of the test and no safe non-interactive substitute exists.

## One paste, one result

When practical, the user should receive one bounded block that:

1. enters the repository;
2. verifies the expected branch and exact HEAD when branch-sensitive;
3. verifies any required clean/known working-tree state;
4. runs the intended generation, formatting, analysis, tests, builds, or diagnostics in the correct order;
5. stops safely at the first unexpected condition;
6. prints the failure output needed for diagnosis;
7. prints a clear final success marker when everything passed;
8. returns control to the user's existing shell without requiring another keypress.

Do not split one deterministic validation sequence into many manual commands merely to make the user relay each intermediate result. Split blocks only when an earlier result genuinely determines what is safe to run next.

## Safe shell behavior

Pasteable blocks execute inside the user's existing interactive shell. Therefore:

- never finish with a bare `exit`;
- do not use `exit 1` in guards that could close the user's shell;
- prefer a function such as `main() { ...; return; }` or nested `if` checks with printed `STOP:` messages;
- use temporary log files when useful so successful noisy steps can be summarized while failures still print complete diagnostics;
- remove temporary log files before returning;
- quote paths and variables safely;
- do not assume that a pager/editor configuration outside the block is safe;
- do not ask the user to diagnose an agent-generated failure.

A malformed, interactive, or shell-closing block is an agent defect.

## Output handoff

The user may paste the command itself together with all resulting output. That is acceptable and should be treated as a complete execution transcript when it includes:

- the emitted branch/HEAD markers;
- step results or failure output;
- the final status/working-tree state;
- the returned shell prompt when visible.

The agent should not ask the user to resend the same information merely because the command text is also present. Read the output portion and proceed.

## Secrets and destructive operations

Non-interactive execution does not override Daymark's security boundaries.

- Never embed or request passwords, keys, signing credentials, journal plaintext, or recovery material in a command block or returned log.
- Use controlled/disposable data for destructive backup/restore, migration, clean-install, or upgrade checks unless the user explicitly chooses otherwise.
- Do not automate a destructive action merely to avoid an interactive confirmation if the confirmation is itself an important product safety boundary. Instead, structure the test with disposable data or stop before the destructive boundary and ask only for the minimum deliberate user action required.

## Git writes

A block may commit or push only when the expected changed-file set is known and prior validation in that same block has passed.

Before committing/pushing, verify:

- expected branch and HEAD;
- expected changed files only;
- `git diff --check` clean;
- applicable formatter/analyzer/tests successful;
- staged file list is exactly the intended scope.

The final repository merge remains separately governed by `AGENTS.md` and `docs/WORKFLOW.md`; local green evidence does not authorize merge or bypass the required `merge-gate`.
