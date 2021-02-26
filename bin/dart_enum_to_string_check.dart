import 'dart:io';

import 'package:dart_enum_to_string_check/src/cli/cli_utils.dart';
import 'package:dart_enum_to_string_check/src/cli/console_runner.dart';

Future<void> main(List<String> arguments) async {
  final root = Directory.current.path;
  final libDirectory = Directory('$root/lib');
  if (!libDirectory.existsSync()) {
    print('Cannot find lib in $root');
    exit(-1);
  }
  final consoleRunner =
      ConsoleRunner(libDirectory, File('$root/analysis_options.yaml'));
  final analysisErrors = await consoleRunner.findAnalysisErrors();
  if (analysisErrors.isEmpty) {
    exit(0);
  } else {
    analysisErrors.map(readableAnalysisError).forEach(print);
    exit(-1);
  }
}
