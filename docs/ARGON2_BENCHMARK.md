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
