# Argon2id benchmark procedure and initial parameter decision

## Purpose

Daymark chooses password-KDF parameters from measurements on real supported hardware rather than from desktop-only assumptions.

Two Flutter profile-mode harnesses are kept in the repository:

- `tool/argon2_benchmark.dart` measures the selected production parameter set;
- `tool/argon2_profile_matrix.dart` compares the OWASP-listed Argon2id memory/iteration tradeoffs used during the initial review.

Both use a fixed synthetic benchmark password and salt. They do not persist, transmit, or require real user credentials.

## Why profile mode

KDF timing must be measured in Flutter profile mode so the result is closer to shipped runtime behavior than a debug/JIT measurement.

Hosted CI timings must not be used to tune password-KDF parameters. CI remains useful for correctness and regression detection, but shared runners are not representative user hardware.

## Selected initial production parameters

Frozen on 2026-09-02 after Linux and physical-Android review:

- algorithm: Argon2id;
- memory: 19 MiB (`19456 KiB`);
- iterations: 2;
- parallelism: 1;
- derived-key length: 32 bytes;
- KDF salt: random 16 bytes per key envelope.

These values are the initial Daymark production baseline for the version-1 key envelope. They are a compatibility-sensitive default once a prerelease containing real journals exists.

They are not intended to be permanent for all future Daymark versions. The key envelope records its KDF parameters explicitly so a future release can use stronger parameters for newly protected material without reinterpreting existing envelopes.

## Why 19 MiB / 2 iterations was retained

At the 2026-09-02 review, the OWASP Password Storage Cheat Sheet listed Argon2id with `m=19456 KiB`, `t=2`, `p=1` as its minimum recommended configuration and also listed lower-memory/higher-iteration tradeoffs including 12 MiB / 3, 9 MiB / 4, and 7 MiB / 5.

Daymark measured those four profiles on:

1. a physical Debian 13 desktop with an Intel Core i5-2400;
2. a physical Samsung SM-A015M / Galaxy A01-class Android device;
3. a deliberately conservative M7 3G PLUS Android 8.1 ARM32 device.

The lower-memory profiles did not produce a compelling enough latency reduction to justify moving away from the higher-memory OWASP baseline:

- on Linux, all four profiles were effectively tied;
- on the Samsung, 7 MiB / 5 was about 6.9% faster than 19 MiB / 2, roughly 107 ms at the median;
- on the M7, 7 MiB / 5 was about 12.8% faster, roughly 551 ms at the median, but still required about 3.75 seconds.

The M7 therefore demonstrates a genuinely slow old-device path rather than a problem uniquely caused by the 19 MiB memory setting. Daymark accepts a slower password-unlock operation on such hardware rather than trading away memory hardness for a modest improvement.

Supporting old hardware is desirable where practical, but old-device support must not silently lower the security baseline. A device may remain supported even when an intentionally expensive security operation is noticeably slower on it.

## Representative single-profile measurements

### Linux: Intel Core i5-2400

Recorded 2026-09-01:

- CPU: Intel Core i5-2400 @ 3.10 GHz;
- logical processors reported: 4;
- memory: 7.7 GiB RAM reported by the OS;
- system: Debian GNU/Linux 13 (trixie), Linux 6.12.94+deb13-amd64;
- Flutter 3.47.2 / Dart 3.13.2;
- parameters: 19 MiB / 2 / p=1 / 32-byte output;
- minimum: 222,517 µs;
- median: 223,827 µs;
- average: 226,079 µs;
- maximum: 232,798 µs.

The result was stable and comfortably below one second.

### Android: M7 3G PLUS

Recorded 2026-09-01:

- Android 8.1.0 / API 27;
- runtime: 32-bit `android_arm`;
- logical processors reported in this run: 4;
- firmware: `ML_WI12_M7_3G_PLUS.V4_20191031`;
- Flutter 3.47.2 / Dart 3.13.2;
- parameters: 19 MiB / 2 / p=1 / 32-byte output;
- minimum: 4,083,909 µs;
- median: 4,190,644 µs;
- average: 4,187,815 µs;
- maximum: 4,299,113 µs.

This is intentionally retained as a conservative old-hardware data point.

### Android: Samsung SM-A015M

Recorded 2026-09-01:

- Android 12 / API 31;
- runtime: 32-bit `android_arm` / `armeabi-v7a`;
- logical processors reported: 8;
- firmware: `SP1A.210812.016.A015MUBS5CWI3`;
- Flutter 3.47.2 / Dart 3.13.2;
- parameters: 19 MiB / 2 / p=1 / 32-byte output;
- minimum: 1,529,112 µs;
- median: 1,541,986 µs;
- average: 1,537,593 µs;
- maximum: 1,544,086 µs.

This shows that the roughly four-second M7 result is not representative of Android hardware in general.

## Equivalent-profile matrix

The matrix compares:

- 19 MiB / 2 iterations / p=1;
- 12 MiB / 3 iterations / p=1;
- 9 MiB / 4 iterations / p=1;
- 7 MiB / 5 iterations / p=1.

Each profile uses one warm-up derivation followed by five measured derivations.

### Median comparison

| Profile | Linux i5-2400 | Samsung SM-A015M | M7 3G PLUS |
| --- | ---: | ---: | ---: |
| 19 MiB / 2 | 228,366 µs | 1,538,213 µs | 4,297,218 µs |
| 12 MiB / 3 | 224,858 µs | 1,465,836 µs | 3,963,560 µs |
| 9 MiB / 4 | 227,339 µs | 1,474,708 µs | 3,964,379 µs |
| 7 MiB / 5 | 226,979 µs | 1,431,396 µs | 3,746,500 µs |

On the Linux machine the complete median spread is only about 3.5 ms, so the profiles are operationally equivalent for desktop latency.

On the Samsung the 7 MiB / 5 profile is the fastest, but the improvement over the selected 19 MiB / 2 profile is only about 107 ms.

On the M7 the 7 MiB / 5 profile is also fastest, but the improvement is about 551 ms and still leaves an approximately 3.75-second derivation.

During the M7 matrix run, Dart reported 2 available processors, while the earlier single-profile M7 run reported 4. Every compared profile uses Argon2 parallelism 1, so the within-run profile comparison remains useful. The difference is preserved as part of the benchmark record rather than hidden.

## Raw matrix evidence

The exact JSON reports are versioned under `docs/argon2-results/`:

- `2026-09-02-linux-i5-2400.json`;
- `2026-09-02-samsung-sm-a015m.json`;
- `2026-09-02-m7-3g-plus.json`.

Do not edit recorded result files merely to make later results look consistent. New measurements should be added as new dated evidence.

## Linux procedure

From the repository root:

```text
flutter run --profile -d linux -t tool/argon2_benchmark.dart
```

For a profile comparison:

```text
flutter run --profile -d linux -t tool/argon2_profile_matrix.dart
```

Record the CPU, memory, OS, Flutter/Dart versions, and complete JSON report. Run on a reasonably idle system. Repeat the complete launch if results vary materially.

## Android physical-device procedure

An emulator is not sufficient for parameter selection.

1. Enable developer options and USB debugging.
2. Connect the device and confirm it appears in `flutter devices`.
3. Run the selected-profile benchmark:

```text
flutter run --profile -d <device-id> -t tool/argon2_benchmark.dart
```

4. For profile comparison, run:

```text
flutter run --profile -d <device-id> -t tool/argon2_profile_matrix.dart
```

5. Keep the device awake and unlocked when using Android UI automation to extract the rendered JSON result. The cryptographic benchmark itself may finish while the screen is off, but `uiautomator` can otherwise capture the lock screen or notification shade instead of Daymark's result view.

Record the device model, Android version, architecture, firmware/platform identifier, Flutter/Dart versions, and complete JSON report. Prefer a normal thermal state.

## Retuning rule

The 19 MiB / 2 / p=1 baseline is frozen for the initial key-envelope design, but security parameters must remain reviewable over the life of the project.

A future default change requires:

1. a concrete security, platform, or performance reason;
2. current external guidance review;
3. representative Linux and physical Android measurements;
4. explicit compatibility handling for existing envelopes;
5. updates to `SECURITY.md`, `docs/ARCHITECTURE.md`, and `PROJECT.md`;
6. final green CI on the reviewed implementation.

Never silently weaken parameters merely to make a slow device or CI runner pass.
