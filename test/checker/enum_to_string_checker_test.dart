import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dart_enum_to_string_check/src/cli/cli_utils.dart';
import 'package:test/test.dart';

void main() {
  group('EnumToStringChecker test', () {
    test('Check with real files', () async {
      final files = [
        '${Directory.current.path}/assets_test/checker/valid_settings.dart',
        '${Directory.current.path}/assets_test/checker/invalid_settings.dart',
      ];
      final analysisContextCollection = AnalysisContextCollection(
        includedPaths: files,
        resourceProvider: PhysicalResourceProvider.INSTANCE,
      );
      final errors =
          await collectAnalyzerErrors(analysisContextCollection, files);
      expect(
        1,
        errors.length,
      );
    });
  });
}
