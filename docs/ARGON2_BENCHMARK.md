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

## Recorded Android result: older ARM32 device

First physical Android measurement, recorded 2026-09-01:

- device: M7 3G PLUS;
- Android 8.1.0 / API 27;
- runtime architecture: 32-bit `android_arm`;
- 4 logical processors;
- firmware/platform identifier: `ML_WI12_M7_3G_PLUS.V4_20191031`;
- Flutter 3.47.2 / Dart 3.13.2;
- profile-mode candidate: 19 MiB memory, 2 iterations, parallelism 1, 32-byte output;
- minimum: 4,083,909 microseconds;
- median: 4,190,644 microseconds;
- average: 4,187,815 microseconds;
- maximum: 4,299,113 microseconds.

Complete harness report:

```json
{
  "benchmark": "daymark-argon2id",
  "platform": "android",
  "platformVersion": "ML_WI12_M7_3G_PLUS.V4_20191031",
  "dartVersion": "3.13.2 (stable) (Tue Aug 25 01:01:12 2026 -0700) on \"android_arm\"",
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
    4083909,
    4104532,
    4190644,
    4260881,
    4299113
  ],
  "minimumMicros": 4083909,
  "medianMicros": 4190644,
  "averageMicros": 4187815,
  "maximumMicros": 4299113
}
```

This is a valid physical-device measurement and an intentionally conservative data point. The current candidate is roughly 18.7 times slower at the median on this older 32-bit Android device than on the recorded Linux machine. A roughly 4.19-second password derivation is too slow to freeze the candidate from this result alone.

## Recorded Android result: Samsung Galaxy A01 class device

Second physical Android measurement, recorded 2026-09-01:

- manufacturer/model: Samsung SM-A015M;
- Android 12 / API 31;
- runtime architecture: 32-bit `android_arm` / `armeabi-v7a`;
- 8 logical processors;
- firmware/platform identifier: `SP1A.210812.016.A015MUBS5CWI3`;
- Flutter 3.47.2 / Dart 3.13.2;
- profile-mode candidate: 19 MiB memory, 2 iterations, parallelism 1, 32-byte output;
- minimum: 1,529,112 microseconds;
- median: 1,541,986 microseconds;
- average: 1,537,593 microseconds;
- maximum: 1,544,086 microseconds.

Complete harness report:

```json
{
  "benchmark": "daymark-argon2id",
  "platform": "android",
  "platformVersion": "SP1A.210812.016.A015MUBS5CWI3",
  "dartVersion": "3.13.2 (stable) (Tue Aug 25 01:01:12 2026 -0700) on \"android_arm\"",
  "processors": 8,
  "warmupRuns": 1,
  "sampleRuns": 5,
  "parameters": {
    "memoryKiB": 19456,
    "iterations": 2,
    "parallelism": 1,
    "hashLength": 32
  },
  "samplesMicros": [
    1529112,
    1530551,
    1541986,
    1542231,
    1544086
  ],
  "minimumMicros": 1529112,
  "medianMicros": 1541986,
  "averageMicros": 1537593,
  "maximumMicros": 1544086
}
```

This second result shows that the roughly 4.19-second M7 result is not representative of Android hardware in general. The same candidate runs at a stable median of roughly 1.54 seconds on this later low-end 32-bit Samsung device. The candidate remains unfrozen because Daymark intentionally values useful support for older hardware where that support does not require weakening the security baseline or accumulating disproportionate compatibility complexity.

## Equivalent-profile comparison

As of this review, the OWASP Password Storage Cheat Sheet lists the following Argon2id parameter sets as equivalent minimum-defense tradeoffs between memory and CPU:

- 19 MiB, 2 iterations, parallelism 1;
- 12 MiB, 3 iterations, parallelism 1;
- 9 MiB, 4 iterations, parallelism 1;
- 7 MiB, 5 iterations, parallelism 1.

The current Daymark candidate is therefore already one of the listed minimum-defense profiles. Do not simply reduce its work factor to make the M7 faster.

`tool/argon2_profile_matrix.dart` benchmarks all four listed profiles independently using the same fixed synthetic password/salt, one warm-up run per profile, and five measured runs per profile. It exists to test whether a lower-memory but higher-iteration equivalent profile behaves materially better on older Android hardware without reducing the intended security floor.

Run it in profile mode:

```text
flutter run --profile -d <device-id> -t tool/argon2_profile_matrix.dart
```

The comparison should be run at least on the conservative M7 Android device and the representative Linux machine before selecting a different profile. Re-run on the Samsung device if the results are close enough that its data would affect the decision.

### Recorded profile matrix: M7 3G PLUS

Recorded 2026-09-02 on the same Android 8.1 / 32-bit ARM M7 device used for the conservative candidate benchmark.

The runtime reported 2 available processors during this matrix run, whereas the earlier single-profile run reported 4. All tested profiles use Argon2 parallelism 1, so the matrix remains useful as a within-run comparison, but this runtime-state difference is retained as part of the record rather than hidden.

Median results:

| Profile | Median |
| --- | ---: |
| 19 MiB / 2 iterations | 4,297,218 µs |
| 12 MiB / 3 iterations | 3,963,560 µs |
| 9 MiB / 4 iterations | 3,964,379 µs |
| 7 MiB / 5 iterations | 3,746,500 µs |

The 7 MiB / 5-iteration profile is the fastest measured equivalent profile on this device, reducing median latency by about 12.8% relative to 19 MiB / 2 iterations in the same run. It is still roughly a 3.75-second derivation, so changing equivalent profiles does not remove the fundamental old-device latency cost.

Complete matrix report:

```json
{
  "benchmark": "daymark-argon2id-profile-matrix",
  "platform": "android",
  "platformVersion": "ML_WI12_M7_3G_PLUS.V4_20191031",
  "dartVersion": "3.13.2 (stable) (Tue Aug 25 01:01:12 2026 -0700) on \"android_arm\"",
  "processors": 2,
  "warmupRunsPerProfile": 1,
  "sampleRunsPerProfile": 5,
  "profiles": [
    {
      "name": "owasp-19m-2t",
      "parameters": {"memoryKiB": 19456, "iterations": 2, "parallelism": 1, "hashLength": 32},
      "samplesMicros": [4087465, 4286610, 4297218, 4329240, 4460395],
      "minimumMicros": 4087465,
      "medianMicros": 4297218,
      "averageMicros": 4292185,
      "maximumMicros": 4460395
    },
    {
      "name": "owasp-12m-3t",
      "parameters": {"memoryKiB": 12288, "iterations": 3, "parallelism": 1, "hashLength": 32},
      "samplesMicros": [3927776, 3935563, 3963560, 4029158, 4035035],
      "minimumMicros": 3927776,
      "medianMicros": 3963560,
      "averageMicros": 3978218,
      "maximumMicros": 4035035
    },
    {
      "name": "owasp-9m-4t",
      "parameters": {"memoryKiB": 9216, "iterations": 4, "parallelism": 1, "hashLength": 32},
      "samplesMicros": [3949588, 3961974, 3964379, 4015834, 4022508],
      "minimumMicros": 3949588,
      "medianMicros": 3964379,
      "averageMicros": 3982856,
      "maximumMicros": 4022508
    },
    {
      "name": "owasp-7m-5t",
      "parameters": {"memoryKiB": 7168, "iterations": 5, "parallelism": 1, "hashLength": 32},
      "samplesMicros": [3672337, 3674621, 3746500, 3845008, 3846700],
      "minimumMicros": 3672337,
      "medianMicros": 3746500,
      "averageMicros": 3757033,
      "maximumMicros": 3846700
    }
  ]
}
```

### Recorded profile matrix: representative Linux

Recorded 2026-09-02 on the existing representative Debian 13 system with Intel Core i5-2400 @ 3.10 GHz and 4 logical processors.

Median results:

| Profile | Median |
| --- | ---: |
| 19 MiB / 2 iterations | 228,366 µs |
| 12 MiB / 3 iterations | 224,858 µs |
| 9 MiB / 4 iterations | 227,339 µs |
| 7 MiB / 5 iterations | 226,979 µs |

All four equivalent profiles are effectively tied on this Linux machine: the complete spread between fastest and slowest median is about 3.5 ms. The lower-memory alternatives therefore offer no meaningful desktop latency advantage here.

Complete matrix report:

```json
{
  "benchmark": "daymark-argon2id-profile-matrix",
  "platform": "linux",
  "platformVersion": "Linux 6.12.94+deb13-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.12.94-1 (2026-06-20)",
  "dartVersion": "3.13.2 (stable) (Tue Aug 25 01:01:12 2026 -0700) on \"linux_x64\"",
  "processors": 4,
  "warmupRunsPerProfile": 1,
  "sampleRunsPerProfile": 5,
  "profiles": [
    {
      "name": "owasp-19m-2t",
      "parameters": {"memoryKiB": 19456, "iterations": 2, "parallelism": 1, "hashLength": 32},
      "samplesMicros": [226908, 228268, 228366, 234156, 236924],
      "minimumMicros": 226908,
      "medianMicros": 228366,
      "averageMicros": 230924,
      "maximumMicros": 236924
    },
    {
      "name": "owasp-12m-3t",
      "parameters": {"memoryKiB": 12288, "iterations": 3, "parallelism": 1, "hashLength": 32},
      "samplesMicros": [222850, 224031, 224858, 225833, 225972],
      "minimumMicros": 222850,
      "medianMicros": 224858,
      "averageMicros": 224708,
      "maximumMicros": 225972
    },
    {
      "name": "owasp-9m-4t",
      "parameters": {"memoryKiB": 9216, "iterations": 4, "parallelism": 1, "hashLength": 32},
      "samplesMicros": [226677, 227198, 227339, 228025, 228595],
      "minimumMicros": 226677,
      "medianMicros": 227339,
      "averageMicros": 227566,
      "maximumMicros": 228595
    },
    {
      "name": "owasp-7m-5t",
      "parameters": {"memoryKiB": 7168, "iterations": 5, "parallelism": 1, "hashLength": 32},
      "samplesMicros": [226597, 226939, 226979, 227964, 229513],
      "minimumMicros": 226597,
      "medianMicros": 226979,
      "averageMicros": 227598,
      "maximumMicros": 229513
    }
  ]
}
```

These two matrix runs do not freeze a new profile. They show that profile choice has negligible effect on the representative Linux machine and only a modest effect on the conservative M7. A second, deliberately old Linux hardware data point may be added before the final parameter decision because Daymark intends to understand legacy-hardware behavior rather than silently optimize only for modern machines.

## Parameter-freeze rule

`Argon2Parameters.productionCandidate` is not a compatibility promise yet.

Before `v1.0.0-alpha.1` may ship with real user journals:

1. Linux and physical Android results must be recorded;
2. the measured latency and memory cost must be reviewed together;
3. any parameter adjustment must be re-measured on both platforms;
4. the selected values must be recorded in `SECURITY.md`, `docs/ARCHITECTURE.md`, and `PROJECT.md`;
5. the key-envelope KDF metadata must continue to carry the parameters explicitly so future versions can strengthen them without reinterpreting existing journals.

Do not silently lower parameters merely to make a slow device or CI runner pass. A parameter change is a reviewed security decision.
