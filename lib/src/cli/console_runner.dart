import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:path/path.dart';
import '../analyzer_plugin/analyzer_plugin.dart';

import 'cli_utils.dart';

/// Runner class for execute plugin from CLI.
class ConsoleRunner {
  final Directory _lib;
  final File _analysisOptions;

  ConsoleRunner(this._lib, this._analysisOptions);

  Future<List<AnalysisError>> findAnalysisErrors() async {
    final paths = [normalize(_lib.path)];
    final excludedFolders = [...DartEnumToStringAnalyzerPlugin.excludedFolders];
    if (_analysisOptions.existsSync()) {
      final folders = excludedFilesFromAnalysisOptions(_analysisOptions);
      excludedFolders.addAll(folders);
    }
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: paths,
      resourceProvider: PhysicalResourceProvider.INSTANCE,
      excludedPaths: excludedFolders,
    );
    final filePaths = resolvePaths(
      paths,
      excludedFolders,
      _lib.path,
    );
    return collectAnalyzerErrors(
      analysisContextCollection,
      filePaths,
    );
  }
}
