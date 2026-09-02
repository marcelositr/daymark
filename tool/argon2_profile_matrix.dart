import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:flutter/material.dart';

const int _warmupRuns = 1;
const int _sampleRuns = 5;
const String _benchmarkPassword = 'daymark-argon2id-benchmark-password';

const List<_Argon2Profile> _profiles = <_Argon2Profile>[
  _Argon2Profile(
    name: 'owasp-19m-2t',
    memoryKiB: 19 * 1024,
    iterations: 2,
    parallelism: 1,
    hashLength: 32,
  ),
  _Argon2Profile(
    name: 'owasp-12m-3t',
    memoryKiB: 12 * 1024,
    iterations: 3,
    parallelism: 1,
    hashLength: 32,
  ),
  _Argon2Profile(
    name: 'owasp-9m-4t',
    memoryKiB: 9 * 1024,
    iterations: 4,
    parallelism: 1,
    hashLength: 32,
  ),
  _Argon2Profile(
    name: 'owasp-7m-5t',
    memoryKiB: 7 * 1024,
    iterations: 5,
    parallelism: 1,
    hashLength: 32,
  ),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Map<String, Object> report = await _runMatrix();
  final String formattedReport = const JsonEncoder.withIndent('  ').convert(
    report,
  );

  stdout.writeln(formattedReport);
  runApp(_BenchmarkResultApp(report: formattedReport));
}

Future<Map<String, Object>> _runMatrix() async {
  final List<int> salt = List<int>.generate(
    KeyEnvelopeService.kdfSaltLength,
    (int index) => index,
    growable: false,
  );

  final List<Map<String, Object>> results = <Map<String, Object>>[];
  for (final _Argon2Profile profile in _profiles) {
    results.add(await _runProfile(profile: profile, salt: salt));
  }

  return <String, Object>{
    'benchmark': 'daymark-argon2id-profile-matrix',
    'platform': Platform.operatingSystem,
    'platformVersion': Platform.operatingSystemVersion,
    'dartVersion': Platform.version,
    'processors': Platform.numberOfProcessors,
    'warmupRunsPerProfile': _warmupRuns,
    'sampleRunsPerProfile': _sampleRuns,
    'profiles': results,
  };
}

Future<Map<String, Object>> _runProfile({
  required _Argon2Profile profile,
  required List<int> salt,
}) async {
  final Argon2id algorithm = Argon2id(
    memory: profile.memoryKiB,
    iterations: profile.iterations,
    parallelism: profile.parallelism,
    hashLength: profile.hashLength,
  );

  for (int index = 0; index < _warmupRuns; index++) {
    await _runSample(algorithm: algorithm, profile: profile, salt: salt);
  }

  final List<int> samplesMicros = <int>[];
  for (int index = 0; index < _sampleRuns; index++) {
    samplesMicros.add(
      await _runSample(algorithm: algorithm, profile: profile, salt: salt),
    );
  }
  samplesMicros.sort();

  final int medianMicros = samplesMicros[samplesMicros.length ~/ 2];
  final int averageMicros =
      samplesMicros.reduce((int left, int right) => left + right) ~/
      samplesMicros.length;

  return <String, Object>{
    'name': profile.name,
    'parameters': <String, Object>{
      'memoryKiB': profile.memoryKiB,
      'iterations': profile.iterations,
      'parallelism': profile.parallelism,
      'hashLength': profile.hashLength,
    },
    'samplesMicros': samplesMicros,
    'minimumMicros': samplesMicros.first,
    'medianMicros': medianMicros,
    'averageMicros': averageMicros,
    'maximumMicros': samplesMicros.last,
  };
}

Future<int> _runSample({
  required Argon2id algorithm,
  required _Argon2Profile profile,
  required List<int> salt,
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  final SecretKey key = await algorithm.deriveKeyFromPassword(
    password: _benchmarkPassword,
    nonce: salt,
  );
  stopwatch.stop();

  try {
    final List<int> derivedBytes = await key.extractBytes();
    if (derivedBytes.length != profile.hashLength) {
      throw StateError('Argon2id returned an unexpected derived-key length.');
    }
  } finally {
    key.destroy();
  }

  return stopwatch.elapsedMicroseconds;
}

final class _Argon2Profile {
  const _Argon2Profile({
    required this.name,
    required this.memoryKiB,
    required this.iterations,
    required this.parallelism,
    required this.hashLength,
  });

  final String name;
  final int memoryKiB;
  final int iterations;
  final int parallelism;
  final int hashLength;
}

final class _BenchmarkResultApp extends StatelessWidget {
  const _BenchmarkResultApp({required this.report});

  final String report;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Daymark Argon2id profile matrix')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(report),
          ),
        ),
      ),
    );
  }
}
