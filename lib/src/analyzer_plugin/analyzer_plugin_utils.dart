import 'package:analyzer/dart/analysis/results.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';

/*
 * Useful utils from https://github.com/wrike/dart-code-metrics
 */

Iterable<Glob> prepareExcludes(Iterable<String> patterns, String root) =>
    patterns?.map((exclude) => Glob(join(root, exclude)))?.toList() ?? [];

bool isExcluded(AnalysisResult result, Iterable<Glob> excludes) =>
    excludes.any((exclude) => exclude.matches(result.path));
