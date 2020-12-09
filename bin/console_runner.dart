import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dart_enum_to_string_check/src/analyzer_plugin/analyzer_plugin_utils.dart';
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
  final excludeFolders = ['.dart_tool/**', 'packages/**', '**/.symlinks/**'];
  final analysisContextCollection = AnalysisContextCollection(
    includedPaths: paths,
    resourceProvider: PhysicalResourceProvider.INSTANCE,
    excludedPaths: excludeFolders,
  );
  final excludeGlobs = excludeFolders.map((path) => Glob(path)).toList();
  final filePaths = paths.expand((path) => Glob('$path/**/*.dart').listSync().whereType<File>().where((file) => !_isExcluded(file.path, excludeGlobs)).map((e) => e.path)).toList();
  final errors = <EnumToStringCheckerIssue>[];
  for (final filePath in filePaths) {
    final normalizedPath = normalize(filePath);
    final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    final errorsInFile = EnumToStringChecker(unit.unit).enumToStringErrors();
    errors.addAll(errorsInFile);
    print(filePath);
  }
  if (errors.isEmpty) {
    exit(0);
  } else {
    exit(-1);
  }
}

// Copied from https://github.com/wrike/dart-code-metrics/blob/master/lib/src/metrics_analyzer.dart
bool _isExcluded(String filePath, Iterable<Glob> excludes) =>
    excludes.any((exclude) => exclude.matches(filePath));
