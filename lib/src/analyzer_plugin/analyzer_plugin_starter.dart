import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';

import 'analyzer_plugin.dart';

/// Entry point of plugin. Dart Analyzer Server runs it from its side.
void start(Iterable<String> _, SendPort sendPort) {
  ServerPluginStarter(
          DartEnumToStringAnalyzerPlugin(PhysicalResourceProvider.INSTANCE))
      .start(sendPort);
}
