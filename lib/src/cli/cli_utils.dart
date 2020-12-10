// Copied from https://github.com/wrike/dart-code-metrics/blob/master/lib/src/metrics_analyzer.dart
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:dart_enum_to_string_check/src/analyzer_plugin/enum_to_string_checker.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

List<String> excludedFilesFromAnalysisOptions(File analysisOptions) {
   final parsedOptions = loadYaml(analysisOptions.readAsStringSync()) as YamlMap;
   final analyzerSection = parsedOptions.nodes['analyzer'];
   if (analysisOptions != null) {
     dynamic excludedSection = (analyzerSection as YamlMap)['exclude'];
     if (excludedSection != null) {
       return (excludedSection as YamlList).map((dynamic path) => path as String).toList();
     }
   }
   return [];
}

List<String> resolvePaths(List<String> paths, List<String> excludedFolders) {
  final excludedGlobs = excludedFolders.map((path) => Glob(path)).toList();
  return paths.expand((path) => Glob('$path/**/*.dart').listSync().whereType<File>().where((file) => !_isExcluded(file.path, excludedGlobs)).map((e) => e.path)).toList();
}

bool _isExcluded(String filePath, Iterable<Glob> excludes) =>
    excludes.any((exclude) => exclude.matches(filePath));

Future<List<EnumToStringCheckerIssue>> findAnalyzerIssues(AnalysisContextCollection analysisContextCollection, List<String> paths,) async {
  final issues = <EnumToStringCheckerIssue>[];
  for (final filePath in paths) {
    final normalizedPath = normalize(filePath);
    final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    final errorsInFile = EnumToStringChecker(unit.unit).enumToStringErrors();
    issues.addAll(errorsInFile);
  }
  return issues;
}
