import 'package:analyzer/dart/analysis/results.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';

/*
 * Useful utils from https://github.com/wrike/dart-code-metrics
 */

/// Prepare excludes for configuration.
Iterable<Glob> prepareExcludes(Iterable<String?> patterns, String root) =>
    patterns.map((exclude) => Glob(join(root, exclude))).toList();

/// Check glob is excluded or not.
bool isExcluded(AnalysisResult result, Iterable<Glob> excludes) =>
    excludes.any((exclude) => exclude.matches(result.path!));
