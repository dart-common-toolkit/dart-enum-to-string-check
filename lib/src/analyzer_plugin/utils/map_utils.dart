import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import '../checker/enum_to_string_checker.dart';

AnalysisError analysisErrorFor(String path, EnumToStringCheckerIssue issue, CompilationUnit unit) {
  final offsetLocation = unit.lineInfo.getLocation(issue.offset);
  return AnalysisError(
    issue.analysisErrorSeverity,
    issue.analysisErrorType,
    Location(
      path,
      issue.offset,
      issue.length,
      offsetLocation.lineNumber,
      offsetLocation.columnNumber,
    ),
    issue.message,
    issue.code,
  );
}
