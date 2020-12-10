import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dart_enum_to_string_check/src/analyzer_plugin/analyzer_plugin.dart';
import 'package:dart_enum_to_string_check/src/cli/cli_utils.dart';

Future<void> main(List<String> arguments) async {
  final root = Directory.current.path;
  final libDirectory = Directory('$root/lib');
  if (!libDirectory.existsSync()) {
    print('Cannot find lib in $root');
    exit(-1);
  }
  final paths = [libDirectory.path];
  final excludedFolders = [...AnalyzerPlugin.excludedFolders];
  final analysisOptions = File('$root/analysis_options.yaml');
  if (analysisOptions.existsSync()) {
    excludedFolders.addAll(
      excludedFilesFromAnalysisOptions(analysisOptions)
    );
  }
  final analysisContextCollection = AnalysisContextCollection(
    includedPaths: paths,
    resourceProvider: PhysicalResourceProvider.INSTANCE,
    excludedPaths: excludedFolders,
  );
  final filePaths = resolvePaths(paths, excludedFolders);
  final issues = await findIssues(analysisContextCollection, filePaths);
  if (issues.isEmpty) {
    exit(0);
  } else {
    exit(-1);
  }
}
