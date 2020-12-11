import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:dart_enum_to_string_check/src/analyzer_plugin/analyzer_plugin.dart';

import 'cli_utils.dart';

class ConsoleRunner {
  final Directory _lib;
  final File _analysisOptions;

  ConsoleRunner(this._lib, this._analysisOptions);

  Future<List<AnalysisError>> findAnalysisErrors() async {
    final paths = [_lib.path];
    final excludedFolders = [...AnalyzerPlugin.excludedFolders];
    if (_analysisOptions.existsSync()) {
      excludedFolders.addAll(
        excludedFilesFromAnalysisOptions(_analysisOptions)
      );
    }
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: paths,
      resourceProvider: PhysicalResourceProvider.INSTANCE,
      excludedPaths: excludedFolders,
    );
    final filePaths = resolvePaths(paths, excludedFolders);
    return collectAnalyzerErrors(analysisContextCollection, filePaths);
  }
}
