# Local validation environment

This document records the primary local machine used as Daymark's Linux development and validation bridge. It is observational, not a minimum-system-requirements document. CI and release requirements remain defined elsewhere.

Last captured: 2026-09-04 (America/Sao_Paulo).

## Host

- Debian GNU/Linux 13.6 (trixie), x86_64.
- Linux kernel 6.12.94+deb13-amd64.
- Intel Core i5-2400, 4 physical cores / 4 threads, 3.10 GHz nominal.
- Approximately 7.7 GiB RAM plus 8.2 GiB swap.
- NVIDIA GeForce GTX 550 Ti using the Mesa/Nouveau Linux graphics stack for Flutter desktop validation.
- Bash 5.2.37 and Git 2.47.3.

The machine is intentionally modest by current build-host standards. Prefer bounded local commands, avoid unnecessary parallel heavyweight builds, and interpret long Android/Gradle build times in that context.

## Native Linux toolchain

- GCC/G++ 14.2.0.
- Clang 19.1.7.
- CMake 3.31.6.
- Ninja 1.12.1.
- pkg-config 1.8.1.
- GTK 3 development package 3.24.49.
- liblzma development package 5.8.1.

`flutter doctor -v` reports the Linux toolchain healthy.

## Flutter / Dart

- Flutter 3.47.2.
- Dart 3.13.2.
- DevTools 2.60.0.
- Daymark constraints: Dart `>=3.13.2 <4.0.0`, Flutter `>=3.47.2`.

The local Flutter installation reports an unknown/user branch even though the framework revision corresponds to the pinned 3.47.2 SDK. Treat the explicit version/revision as the validation baseline and do not run an unplanned Flutter upgrade/channel switch merely to silence that warning.

Chrome/web support is absent and is irrelevant to the current Linux + Android product targets.

## Java / Android

- OpenJDK/Javac 21.0.12.1 from the system PATH.
- `JAVA_HOME` is not explicitly set; Flutter correctly resolves `/usr/bin/java`.
- Android SDK 36.0.0.
- Installed Android platforms: 35 and 36.
- Android build-tools 36.0.0.
- Android platform-tools/ADB 37.0.1.
- Android NDK 28.2.13676358.
- Android licenses accepted.

Daymark Android build configuration at this checkpoint:

- Gradle wrapper 9.3.1.
- Android Gradle Plugin 9.1.0.
- Kotlin Android plugin declaration 2.4.0.
- `android.useAndroidX=true`.
- Flutter compatibility flags `android.newDsl=false` and `android.builtInKotlin=false`.

These AGP 9 compatibility flags are significant when evaluating Flutter plugins. A plugin that assumes AGP 9 always means built-in Kotlin can fail registration even though the host Android toolchain itself is healthy.

## Resource note

Repository `android/gradle.properties` currently allows Gradle up to `-Xmx8G`, while this local host has about 7.7 GiB of physical RAM. This is not by itself a build defect, because the JVM does not eagerly allocate the maximum heap, but memory-heavy builds can push this machine into swap and become slow. Do not diagnose slow local Gradle execution as a code failure solely from duration.

Any future tuning of repository-wide Gradle memory limits should be measured separately and must consider CI as well as this local host.

## Local execution policy

Pasteable validation blocks must follow `docs/LOCAL_EXECUTION.md`: non-interactive by default, no pager/editor surprises, bounded stop conditions, and visible result delimiters for easy copy/paste handoff.
