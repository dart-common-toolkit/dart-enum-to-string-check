import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dart_enum_to_string_check/src/analyzer_plugin/enum_to_string_checker.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';

Future<void> main(List<String> arguments) async {
  final root = Directory.current.path;
  final libPath = '$root/lib';
  if (!Directory(libPath).existsSync()) {
    print('Cannot find lib in $root');
    exit(-1);
  }
  final paths = [libPath];
  final analysisContextCollection = AnalysisContextCollection(
    includedPaths: paths,
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );
  final filePaths = paths.expand((path) => Glob('$path/**/*.dart').listSync().whereType<File>().map((e) => e.path)).toList();
  final errors = <EnumToStringCheckerIssue>[];
  for (final filePath in filePaths) {
    final normalizedPath = normalize(filePath);
    final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    final errorsInFile = EnumToStringChecker(unit.unit).enumToStringErrors();
    errors.addAll(errorsInFile);
  }
  if (errors.isEmpty) {
    exit(0);
  } else {
    exit(-1);
  }
}
