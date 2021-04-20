import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import '../checker/enum_to_string_checker.dart';

/// Get error for [CompilationUnit] unit.
AnalysisError analysisErrorFor(
  String path,
  EnumToStringCheckerIssue issue,
  CompilationUnit unit,
) {
  final offsetLocation = unit.lineInfo!.getLocation(issue.offset);
  return AnalysisError(
    issue.analysisErrorSeverity,
    issue.analysisErrorType,
    Location(
      path,
      issue.offset,
      issue.length,
      offsetLocation.lineNumber,
      offsetLocation.columnNumber,
      -1,
      -1,
    ),
    issue.message,
    issue.code,
  );
}
