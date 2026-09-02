# Argon2id benchmark procedure

## Purpose

Daymark must choose password-KDF parameters from representative measurements on both initial platforms rather than from desktop-only assumptions.

The benchmark entry point is `tool/argon2_benchmark.dart`. It uses synthetic fixed password/salt input, runs one warm-up derivation followed by five measured derivations, and reports the current `Argon2Parameters.productionCandidate` as JSON.

The harness does not persist, transmit, or require real user credentials.

## Why profile mode

KDF timing must be measured in Flutter profile mode so the result is closer to shipped runtime behavior than a debug/JIT measurement.

Do not use normal CI runner timings to freeze production parameters. Hosted runner results may be useful for regression investigation, but they are not representative user hardware.

## Linux procedure

From the repository root on a representative supported Linux machine:

```text
flutter run --profile -d linux -t tool/argon2_benchmark.dart
```

Record:

- hardware model / CPU;
- memory size;
- Linux distribution and version;
- Flutter/Dart version;
- the complete JSON report emitted by the harness.

Run the benchmark from a reasonably idle system. Repeat the complete launch at least three times if results vary materially.

## Recorded Linux result

First representative local measurement, recorded 2026-09-01:

- CPU: Intel Core i5-2400 @ 3.10 GHz, 4 logical processors;
- memory: 7.7 GiB RAM reported by the operating system;
- system: Debian GNU/Linux 13 (trixie), Linux 6.12.94+deb13-amd64;
- Flutter 3.47.2 / Dart 3.13.2;
- profile-mode candidate: 19 MiB memory, 2 iterations, parallelism 1, 32-byte output;
- minimum: 222,517 microseconds;
- median: 223,827 microseconds;
- average: 226,079 microseconds;
- maximum: 232,798 microseconds.

Complete harness report:

```json
{
  "benchmark": "daymark-argon2id",
  "platform": "linux",
  "platformVersion": "Linux 6.12.94+deb13-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.12.94-1 (2026-06-20)",
  "dartVersion": "3.13.2 (stable) (Tue Aug 25 01:01:12 2026 -0700) on \"linux_x64\"",
  "processors": 4,
  "warmupRuns": 1,
  "sampleRuns": 5,
  "parameters": {
    "memoryKiB": 19456,
    "iterations": 2,
    "parallelism": 1,
    "hashLength": 32
  },
  "samplesMicros": [
    222517,
    223208,
    223827,
    228047,
    232798
  ],
  "minimumMicros": 222517,
  "medianMicros": 223827,
  "averageMicros": 226079,
  "maximumMicros": 232798
}
```

This measurement is sufficiently stable to count as the Linux data point. It does not by itself freeze production parameters; physical Android validation remains required.

## Android physical-device procedure

An emulator is not sufficient for freezing production KDF parameters.

1. Enable developer options and USB debugging on a representative Android device.
2. Connect the device and confirm that Flutter sees it with `flutter devices`.
3. From the repository root, run:

```text
flutter run --profile -d <device-id> -t tool/argon2_benchmark.dart
```

Record:

- device model;
- Android version;
- approximate device class / age;
- Flutter/Dart version;
- the complete JSON report emitted by the harness.

Run the benchmark on physical hardware with the device in a normal thermal state. Repeat the complete launch at least three times if results vary materially.

## Parameter-freeze rule

`Argon2Parameters.productionCandidate` is not a compatibility promise yet.

Before `v1.0.0-alpha.1` may ship with real user journals:

1. Linux and physical Android results must be recorded;
2. the measured latency and memory cost must be reviewed together;
3. any parameter adjustment must be re-measured on both platforms;
4. the selected values must be recorded in `SECURITY.md`, `docs/ARCHITECTURE.md`, and `PROJECT.md`;
5. the key-envelope KDF metadata must continue to carry the parameters explicitly so future versions can strengthen them without reinterpreting existing journals.

Do not silently lower parameters merely to make a slow device or CI runner pass. A parameter change is a reviewed security decision.
