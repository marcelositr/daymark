# Local performance benchmark

This document defines how Daymark performance measurements should be run on the primary local validation host and records the current baseline. It is a development aid, not a product performance requirement and not a substitute for CI.

The host profile lives in `docs/LOCAL_ENVIRONMENT.md`; terminal-block behavior lives in `docs/LOCAL_EXECUTION.md`.

Last baseline: 2026-09-04 (America/Sao_Paulo).

## Purpose

Use these measurements to decide whether a build/tooling change actually improves local iteration speed. Do not keep Gradle, Flutter, JVM, cache, or parallelism tuning merely because it sounds faster.

A tuning change is worth keeping only when repeated measurements show a useful improvement without making memory pressure, swap use, stability, CI behavior, or repository reproducibility worse.

## Benchmark categories

Keep these categories separate because they answer different questions.

### Full Flutter test suite

Measures the complete local Dart/Flutter test cost on the pinned toolchain. This should normally run from a warm dependency cache and should not be preceded by `flutter clean`.

### Controlled Linux rebuild

Remove only `build/linux`, then run the Linux debug build. This measures a target-specific rebuild while preserving the global Flutter/pub caches.

Do not use `flutter clean` for the ordinary benchmark because it destroys caches unrelated to the target and makes the result less representative of normal development.

### Warm Linux incremental build

Immediately repeat the same Linux debug build without changing source or deleting build output. This measures the fast path the development loop should preserve.

### Controlled Android rebuild

Stop the existing Gradle daemon if a cold-daemon comparison is intended, then run Gradle's Android-target clean before the debug APK build. Do not wipe the whole Flutter project cache.

This is deliberately more expensive than normal development and exists to compare Android/Gradle changes under a repeatable rebuild condition.

### Warm Android incremental build

Immediately repeat the Android debug APK build without source changes or cleanup. This is the most relevant number for ordinary repeated Android work.

## Measurement rules

- Start from the exact expected branch/HEAD and a clean working tree.
- Record CPU model/core count, load average, memory, swap, Flutter/Dart, Java, and Gradle versions when the environment may have changed.
- Resolve the locked dependency set once before timed commands, then use `--no-pub` where supported so network/dependency resolution does not pollute build timing.
- Do not install packages, change governors, change swap, kill unrelated user processes, or modify repository configuration merely to make a benchmark look faster.
- Avoid unrelated heavyweight work while measuring when practical.
- Capture real elapsed time plus approximate peak process-tree RSS, sampled CPU use, minimum system memory available, and maximum swap used.
- Preserve a clean worktree at the end.
- Change one tuning variable at a time. Compare against the same benchmark category, not against a different warm/cold state.
- Repeat promising A/B results before making a repository-wide tuning change permanent.

The local host does not currently have `/usr/bin/time`; the accepted benchmark harness therefore uses Python plus `/proc` sampling and requires no additional package installation.

## Baseline: 2026-09-04

Host state before the run:

- Intel Core i5-2400, 4 cores / 4 threads;
- CPU governor `schedutil`;
- approximately 7.7 GiB physical RAM;
- swap initially unused;
- Flutter 3.47.2 / Dart 3.13.2;
- Java 21.0.12.1;
- Gradle 9.3.1;
- Daymark HEAD `a7fd2dfd5b408b0285ac88a7bf610041cf8c299d` on `feat/backup-restore-ui`.

| Measurement | Real time | Peak tree RSS | Peak sampled CPU | Min available RAM | Max swap used |
| --- | ---: | ---: | ---: | ---: | ---: |
| Full Flutter test suite | 54.99 s | 1394.4 MiB | 280.3% | 3244.0 MiB | 0.5 MiB |
| Linux debug rebuild | 9.37 s | 446.9 MiB | 282.8% | 4539.9 MiB | 0.5 MiB |
| Linux debug warm incremental | 4.30 s | 364.2 MiB | 172.0% | 4526.0 MiB | 0.5 MiB |
| Android debug APK rebuild | 140.96 s | 2643.1 MiB | 389.5% | 3331.1 MiB | 938.0 MiB |
| Android debug APK warm incremental | 31.71 s | 182.3 MiB | 164.8% | 3854.2 MiB | 938.2 MiB |

## Interpretation of the baseline

The Android rebuild already reaches roughly 390% sampled CPU on a four-core host, so lack of CPU parallelism is not the obvious primary bottleneck. Blindly enabling more parallel work may increase contention rather than reduce elapsed time.

The strongest practical speedup is preserving incremental state:

- Android warm incremental is more than four times faster than the controlled rebuild;
- Linux warm incremental is more than twice as fast as the controlled rebuild.

The Android rebuild also pushes the host into roughly 0.9 GiB of swap. That makes memory behavior a legitimate part of future tuning. Repository `android/gradle.properties` currently permits `-Xmx8G`, but the baseline does not prove that lowering or raising the heap will help. Any heap change must be A/B measured.

## Planned tuning experiments

When there is time for tooling optimization, test these independently before combining them:

1. `org.gradle.caching=true`;
2. `org.gradle.parallel=true`;
3. both together only after individual results are understood;
4. a more conservative Gradle JVM heap only if memory/swap measurements justify it.

Do not commit any of these merely because one run is faster. Repeat the relevant cold and warm Android measurements and verify that Linux/CI behavior remains healthy.

## Normal development implication

Performance benchmarking is exceptional. Normal Daymark development should prefer:

- no unnecessary `flutter clean`;
- warm Flutter/pub/Gradle caches;
- focused tests while implementing;
- one platform build when only one target is relevant;
- full suite and both native builds at meaningful checkpoints;
- exact-head Ready CI as the independent merge gate.
