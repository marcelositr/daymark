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

### Visual result delimiters

For long blocks, print a conspicuous ANSI-red boundary immediately before the result section and another at the end. This lets the user copy only the evidence instead of resending the command itself.

A typical helper is:

```bash
red() {
  printf '\033[1;31m%s\033[0m\n' "$1"
}
```

Use messages such as `COPIE O RESULTADO A PARTIR DESTA LINHA` and `FIM DO RESULTADO`. The block must still remain understandable when ANSI color is unavailable, so the text boundary matters more than the color itself.

## Performance benchmarking

Performance benchmarks are exceptional diagnostics, not the default validation path. The detailed benchmark protocol and current baseline live in `docs/PERFORMANCE_BENCHMARK.md`.

Benchmark blocks must preserve the distinction between controlled rebuilds and normal warm incremental work.

- Do not run `flutter clean` during ordinary development validation or merely to make a benchmark look more rigorous. It destroys useful incremental state across targets and makes normal iteration slower.
- For a controlled Linux rebuild, remove only `build/linux`.
- For a controlled Android rebuild, use an Android/Gradle-target clean when the experiment specifically needs a rebuild baseline; do not wipe unrelated Flutter/pub caches.
- Resolve the locked dependency set once before timed commands and use `--no-pub` where supported so dependency/network work does not contaminate timing.
- Measure a warm incremental build immediately after the corresponding controlled rebuild without source changes.
- Record elapsed time and resource pressure when practical, including process-tree RSS, sampled CPU use, available memory, and swap use.
- If `/usr/bin/time` is unavailable, do not install packages automatically; a Python + `/proc` sampler is an accepted zero-install fallback on the current Linux host.
- Change one tuning variable at a time. Do not combine Gradle caching, parallelism, heap, daemon, governor, or swap changes in a single A/B experiment unless the individual effects are already understood.
- A faster single run is not enough to justify a repository-wide setting. Repeat promising results and reject changes that worsen stability, memory pressure, CI behavior, or reproducibility.
- Preserve a clean worktree before and after the benchmark. A benchmark must not silently commit tuning changes.

Normal Daymark work should optimize the development loop by preserving warm caches, running focused tests while implementing, and reserving full suite/both-platform builds for meaningful checkpoints.

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
