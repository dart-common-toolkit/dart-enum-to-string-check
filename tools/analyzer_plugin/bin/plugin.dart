import 'dart:isolate';

import 'package:dart_enum_to_string_check/analyzer_plugin.dart';

void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}
