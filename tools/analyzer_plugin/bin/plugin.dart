import 'dart:isolate';

import 'package:dart_enum_to_string_check/dart_enum_to_string_check.dart';

void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}
