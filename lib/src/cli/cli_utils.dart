import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import '../analyzer_plugin/checker/enum_to_string_checker.dart';
import '../analyzer_plugin/utils/map_utils.dart';

List<String> excludedFilesFromAnalysisOptions(File analysisOptions) {
   final parsedOptions = loadYaml(analysisOptions.readAsStringSync()) as YamlMap;
   final analyzerSection = parsedOptions.nodes['analyzer'];
   if (analysisOptions != null) {
     final dynamic excludedSection = (analyzerSection as YamlMap)['exclude'];
     if (excludedSection != null) {
       // ignore: avoid_annotating_with_dynamic
       return (excludedSection as YamlList).map((dynamic path) => path as String).toList();
     }
   }
   return [];
}

List<String> resolvePaths(List<String> paths, List<String> excludedFolders) {
  final excludedGlobs = excludedFolders.map((path) => Glob(path)).toList();
  return paths.expand((path) => Glob('$path/**/*.dart').listSync().whereType<File>().where((file) => !_isExcluded(file.path, excludedGlobs)).map((e) => e.path)).toList();
}

// Copied from https://github.com/wrike/dart-code-metrics/blob/master/lib/src/metrics_analyzer.dart
bool _isExcluded(String filePath, Iterable<Glob> excludes) =>
    excludes.any((exclude) => exclude.matches(filePath));

Future<List<AnalysisError>> collectAnalyzerErrors(AnalysisContextCollection analysisContextCollection, List<String> paths) async {
  final analysisErrors = <AnalysisError>[];
  for (final filePath in paths) {
    final normalizedPath = normalize(filePath);
    final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    final issuesInFile = EnumToStringChecker(unit.unit).enumToStringErrors();
    analysisErrors.addAll(issuesInFile.map((issue) => analysisErrorFor(filePath, issue, unit.unit)));
  }
  return analysisErrors;
}

String readableAnalysisError(AnalysisError analysisError) => analysisError.toReadableString();

extension ReadableOutput on AnalysisError {
  String toReadableString() => '$severity - $type\n$message\n${location.file}:${location.startLine}:${location.startColumn}';
}
