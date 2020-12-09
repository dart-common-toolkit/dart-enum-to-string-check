import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
// ignore: implementation_imports
import 'package:analyzer/src/context/builder.dart';
// ignore: implementation_imports
import 'package:analyzer/src/context/context_root.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:glob/glob.dart';
import 'package:dart_enum_to_string_check/src/analyzer_plugin/analyzer_plugin_utils.dart';
import 'package:dart_enum_to_string_check/src/analyzer_plugin/enum_to_string_checker.dart';

class MetricsAnalyzerPlugin extends ServerPlugin {
  final _excludeFolders = ['.dart_tool/**', 'packages/**', '**/.symlinks/**'];
  final _excludedGlobs = <Glob>[];

  var _filesFromSetPriorityFilesRequest = <String>[];

  @override
  String get contactInfo => '';

  @override
  List<String> get fileGlobsToAnalyze => const ['*.dart'];

  @override
  String get name => 'Dart Enum.toString() Check';

  @override
  String get version => '1.0.0';

  MetricsAnalyzerPlugin(ResourceProvider provider) : super(provider);

  @override
  void contentChanged(String path) {
    super.driverForPath(path).addFile(path);
  }

  @override
  AnalysisDriverGeneric createAnalysisDriver(plugin.ContextRoot contextRoot) {
    final root = ContextRoot(contextRoot.root, contextRoot.exclude,
        pathContext: resourceProvider.pathContext)
      ..optionsFilePath = contextRoot.optionsFile;

    final contextBuilder = ContextBuilder(resourceProvider, sdkManager, null)
      ..analysisDriverScheduler = analysisDriverScheduler
      ..byteStore = byteStore
      ..performanceLog = performanceLog
      ..fileContentOverlay = fileContentOverlay;

    _excludedGlobs.addAll(
      prepareExcludes(_excludeFolders, root.root)
    );
    final dartDriver = contextBuilder.buildDriver(root);
    runZonedGuarded(() {
      dartDriver.results.listen((analysisResult) {
        _processResult(dartDriver, analysisResult);
      });
    }, (e, stackTrace) {
      channel.sendNotification(
          plugin.PluginErrorParams(false, e.toString(), stackTrace.toString())
              .toNotification());
    });
    return dartDriver;
  }

  void _processResult(
      AnalysisDriver driver, ResolvedUnitResult analysisResult) {
    try {
      if (analysisResult.unit != null &&
          analysisResult.libraryElement != null &&
          !_excludedGlobs.any((glob) => glob.matches(analysisResult.path))) {
          final enumToStringChecker = EnumToStringChecker(analysisResult.unit);
          final issues = enumToStringChecker.enumToStringErrors();
          if (issues.isNotEmpty) {
            channel.sendNotification(
              plugin.AnalysisErrorsParams(
                analysisResult.path,
                issues.map((issue) {
                  final offsetLocation = analysisResult.lineInfo.getLocation(issue.offset);
                  return plugin.AnalysisError(
                    issue.analysisErrorSeverity,
                    issue.analysisErrorType,
                    plugin.Location(
                      analysisResult.path,
                      issue.offset,
                      issue.length,
                      offsetLocation.lineNumber,
                      offsetLocation.columnNumber,
                    ),
                    issue.message,
                    issue.code,
                  );
                }).toList(),
              ).toNotification(),
            );
          }
      } else {
        channel.sendNotification(
            plugin.AnalysisErrorsParams(analysisResult.path, [])
                .toNotification());
      }
    } on Exception catch (e, stackTrace) {
      channel.sendNotification(
          plugin.PluginErrorParams(false, e.toString(), stackTrace.toString())
              .toNotification());
    }
  }

  /*
   * Code below is a fix to handle files to Analyzer from https://github.com/wrike/dart-code-metrics
   */

  @override
  Future<plugin.AnalysisSetPriorityFilesResult> handleAnalysisSetPriorityFiles(
      plugin.AnalysisSetPriorityFilesParams parameters) async {
    _filesFromSetPriorityFilesRequest = parameters.files;
    _updatePriorityFiles();
    return plugin.AnalysisSetPriorityFilesResult();
  }

  void _updatePriorityFiles() {
    final filesToFullyResolve = {
      ..._filesFromSetPriorityFilesRequest,
      for (final driver2 in driverMap.values)
        ...(driver2 as AnalysisDriver).addedFiles,
    };
    final filesByDriver = <AnalysisDriverGeneric, List<String>>{};
    for (final file in filesToFullyResolve) {
      final contextRoot = contextRootContaining(file);
      if (contextRoot != null) {
        final driver = driverMap[contextRoot];
        filesByDriver.putIfAbsent(driver, () => <String>[]).add(file);
      }
    }
    filesByDriver.forEach((driver, files) => driver.priorityFiles = files);
  }
}
