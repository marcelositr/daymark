import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:flutter/material.dart';

const int _warmupRuns = 1;
const int _sampleRuns = 5;
const String _benchmarkPassword = 'daymark-argon2id-benchmark-password';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Map<String, Object> report = await _runBenchmark();
  final String formattedReport = const JsonEncoder.withIndent('  ').convert(
    report,
  );

  stdout.writeln(formattedReport);
  runApp(_BenchmarkResultApp(report: formattedReport));
}

Future<Map<String, Object>> _runBenchmark() async {
  final Argon2Parameters parameters = Argon2Parameters.productionCandidate;
  final Argon2id algorithm = Argon2id(
    memory: parameters.memoryKiB,
    iterations: parameters.iterations,
    parallelism: parameters.parallelism,
    hashLength: parameters.hashLength,
  );
  final List<int> salt = List<int>.generate(
    KeyEnvelopeService.kdfSaltLength,
    (int index) => index,
    growable: false,
  );

  for (int index = 0; index < _warmupRuns; index++) {
    await _runSample(algorithm: algorithm, salt: salt, parameters: parameters);
  }

  final List<int> samplesMicros = <int>[];
  for (int index = 0; index < _sampleRuns; index++) {
    samplesMicros.add(
      await _runSample(
        algorithm: algorithm,
        salt: salt,
        parameters: parameters,
      ),
    );
  }
  samplesMicros.sort();

  final int medianMicros = samplesMicros[samplesMicros.length ~/ 2];
  final int averageMicros =
      samplesMicros.reduce((int left, int right) => left + right) ~/
      samplesMicros.length;

  return <String, Object>{
    'benchmark': 'daymark-argon2id',
    'platform': Platform.operatingSystem,
    'platformVersion': Platform.operatingSystemVersion,
    'dartVersion': Platform.version,
    'processors': Platform.numberOfProcessors,
    'warmupRuns': _warmupRuns,
    'sampleRuns': _sampleRuns,
    'parameters': <String, Object>{
      'memoryKiB': parameters.memoryKiB,
      'iterations': parameters.iterations,
      'parallelism': parameters.parallelism,
      'hashLength': parameters.hashLength,
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
  required List<int> salt,
  required Argon2Parameters parameters,
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  final SecretKey key = await algorithm.deriveKeyFromPassword(
    password: _benchmarkPassword,
    nonce: salt,
  );
  stopwatch.stop();

  try {
    final List<int> derivedBytes = await key.extractBytes();
    if (derivedBytes.length != parameters.hashLength) {
      throw StateError('Argon2id returned an unexpected derived-key length.');
    }
  } finally {
    key.destroy();
  }

  return stopwatch.elapsedMicroseconds;
}

final class _BenchmarkResultApp extends StatelessWidget {
  const _BenchmarkResultApp({required this.report});

  final String report;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Daymark Argon2id benchmark')),
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
