import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:dart_enum_to_string_check/src/analyzer_plugin/analyzer_plugin.dart';

void start(Iterable<String> _, SendPort sendPort) {
  ServerPluginStarter(
    AnalyzerPlugin(PhysicalResourceProvider.INSTANCE)
  ).start(sendPort);
}
