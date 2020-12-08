import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dart_enum_to_string_check/src/analyzer_plugin/enum_to_string_checker.dart';
import 'package:path/path.dart';

Future<void> main(List<String> arguments) async {
  final analysisContextCollection = AnalysisContextCollection(
    includedPaths: [Platform.script.path],
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );
  final normalizedPath = normalize(Platform.script.path);
  final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
  final errors = EnumToStringChecker(unit.unit).enumToStringErrors();
  print(errors);
}
