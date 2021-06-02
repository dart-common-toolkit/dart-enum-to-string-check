import 'dart:async';

import 'package:analyzer/dart/analysis/context_builder.dart';
import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver_based_analysis_context.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:dart_enum_to_string_check/src/analyzer_plugin/utils/map_utils.dart';
import 'package:glob/glob.dart';

import 'checker/enum_to_string_checker.dart';

/// Plugin class. Root for all data manipulations in plugin.
class DartEnumToStringAnalyzerPlugin extends ServerPlugin {
  static const excludedFolders = [
    '.dart_tool/**',
    'packages/**',
    '**/.symlinks/**'
  ];
  final _excludedGlobs = <Glob>[];

  var _filesFromSetPriorityFilesRequest = <String>[];

  @override
  String get contactInfo =>
      'https://github.com/fartem/dart-enum-to-string-check';

  @override
  List<String> get fileGlobsToAnalyze => const ['*.dart'];

  @override
  String get name => 'Dart Enum.toString() Check';

  @override
  String get version => '1.0.0';

  DartEnumToStringAnalyzerPlugin(ResourceProvider provider) : super(provider);

  @override
  void contentChanged(String path) {
    super.driverForPath(path)?.addFile(path);
  }

  @override
  AnalysisDriverGeneric createAnalysisDriver(plugin.ContextRoot contextRoot) {
    final rootPath = contextRoot.root;
    final locator = ContextLocator(
      resourceProvider: resourceProvider,
    ).locateRoots(
      includedPaths: [rootPath],
      excludedPaths: contextRoot.exclude,
      optionsFile: contextRoot.optionsFile,
    );

    final builder = ContextBuilder(
      resourceProvider: resourceProvider,
    );
    final context = builder.createContext(
      contextRoot: locator.first,
    ) as DriverBasedAnalysisContext;
    final dartDriver = context.driver;

    runZonedGuarded(
      () {
        dartDriver.results.listen((analysisResult) {
          _processResult(
            dartDriver,
            analysisResult,
          );
        });
      },
      (e, stackTrace) {
        channel.sendNotification(
          plugin.PluginErrorParams(
            false,
            e.toString(),
            stackTrace.toString(),
          ).toNotification(),
        );
      },
    );
    return dartDriver;
  }

  void _processResult(
    AnalysisDriver driver,
    ResolvedUnitResult analysisResult,
  ) {
    try {
      if (analysisResult.unit != null &&
          !_excludedGlobs.any((glob) => glob.matches(analysisResult.path!))) {
        final enumToStringChecker = EnumToStringChecker(analysisResult.unit);
        final issues = enumToStringChecker.enumToStringErrors();
        if (issues.isNotEmpty) {
          channel.sendNotification(
            plugin.AnalysisErrorsParams(
              analysisResult.path!,
              issues
                  .map(
                    (issue) => analysisErrorFor(
                      analysisResult.path!,
                      issue,
                      analysisResult.unit!,
                    ),
                  )
                  .toList(),
            ).toNotification(),
          );
        }
      } else {
        channel.sendNotification(
          plugin.AnalysisErrorsParams(
            analysisResult.path!,
            [],
          ).toNotification(),
        );
      }
    } on Exception catch (e, stackTrace) {
      channel.sendNotification(
        plugin.PluginErrorParams(
          false,
          e.toString(),
          stackTrace.toString(),
        ).toNotification(),
      );
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
    final filesByDriver = <AnalysisDriverGeneric?, List<String>>{};
    for (final file in filesToFullyResolve) {
      final contextRoot = contextRootContaining(file);
      if (contextRoot != null) {
        final driver = driverMap[contextRoot];
        filesByDriver.putIfAbsent(driver, () => <String>[]).add(file);
      }
    }
    filesByDriver.forEach((driver, files) => driver!.priorityFiles = files);
  }
}
