import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;

/// Main check. Using for get issues from Dart Analyzer and cast it to [EnumToStringCheckerIssue].
class EnumToStringChecker {
  /// [CompilationUnit] for extract details for issues
  final CompilationUnit _compilationUnit;

  EnumToStringChecker(this._compilationUnit);

  /// Parse errors from Dart Analyer and cast to [EnumToStringCheckerIssue].
  Iterable<EnumToStringCheckerIssue> enumToStringErrors() {
    final visitor = _EnumToStringCheckerVisitor();
    _compilationUnit.accept(visitor);
    return visitor.issues;
  }
}

class _EnumToStringCheckerVisitor extends RecursiveAstVisitor<void> {
  final _issues = <EnumToStringCheckerIssue>[];

  Iterable<EnumToStringCheckerIssue> get issues => _issues;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    if (node.methodName.name == 'toString') {
      final targetType = node.target.staticType;
      if (targetType is InterfaceType) {
        final element = targetType.element;
        if (element.isEnum) {
          _issues.add(
            EnumToStringCheckerIssue(
              plugin.AnalysisErrorSeverity.ERROR,
              plugin.AnalysisErrorType.LINT,
              node.offset,
              node.length,
              'enum.toString() usage error',
              'enum.toString() usage error',
            ),
          );
        }
      }
    }
  }
}

/// Representation of issue that plugin use in internal methods.
class EnumToStringCheckerIssue {
  final plugin.AnalysisErrorSeverity analysisErrorSeverity;
  final plugin.AnalysisErrorType analysisErrorType;
  final int offset;
  final int length;
  final String message;
  final String code;

  EnumToStringCheckerIssue(
    this.analysisErrorSeverity,
    this.analysisErrorType,
    this.offset,
    this.length,
    this.message,
    this.code,
  );
}
