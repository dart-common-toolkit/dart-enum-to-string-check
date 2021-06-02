import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dart_enum_to_string_check/src/cli/cli_utils.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group(
    'EnumToStringChecker test',
    () {
      test(
        'Check multiple files (one with issus, one without issues)',
        () async {
          final files = [
            '${Directory.current.path}/assets_test/checker/valid_settings.dart',
            '${Directory.current.path}/assets_test/checker/invalid_settings.dart',
          ];
          await _checkFiles(files, 1);
        },
      );
      test(
        'Check file with issues',
        () async {
          final files = [
            '${Directory.current.path}/assets_test/checker/invalid_settings.dart',
          ];
          await _checkFiles(files, 1);
        },
      );
      test(
        'Check file without issues',
        () async {
          final files = [
            '${Directory.current.path}/assets_test/checker/valid_settings.dart',
          ];
          await _checkFiles(files, 0);
        },
      );
    },
  );
}

Future<void> _checkFiles(List<String> files, int issuesCount) async {
  final normalized = files.map((file) => normalize(file)).toList();
  final analysisContextCollection = AnalysisContextCollection(
    includedPaths: normalized,
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );
  final issues = await collectAnalyzerErrors(analysisContextCollection, files);
  expect(
    issuesCount,
    issues.length,
  );
}
