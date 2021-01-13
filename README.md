# dart_enum_to_string_check

[![GitHubActions](https://github.com/fartem/dart-enum-to-string-check/workflows/Dart/badge.svg)](https://github.com/fartem/dart-enum-to-string-check/actions?query=workflow%3ADart)
[![Coverage](./coverage_badge.svg)](./coverage_badge.svg)
[![pub.dev](https://img.shields.io/pub/v/dart_enum_to_string_check.svg)](https://pub.dartlang.org/packages/dart_enum_to_string_check)

## About

Plugin for Dart Analyzer to checking enum.toString() usages.

## Motivation

Default Enum.toString() method represents a enum constant as class name + constant name (example: `Colors.green` but not `green`). In some cases this cast is not valid for a program logic (parse values to DB or JSON and vice versa) and can causing some problems (when from DB you get a strings without class names, `"green" == Colors.green.toString()` is not as we needed). Plugin helps to prevent described problem.

## How to use

### From Dart Analyzer Server

Add plugin as development dependency in `pubspec.yml`:

```yaml
dev_dependencies:

  dart_enum_to_string_check: ^0.6.2

```

Add plugin name to `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - dart_enum_to_string_check
```

Then restart Dart Analyzer Server.

### From CLI

#### With pub

To get `dart_enum_to_string_check` from `pub`, run from the shell:

__Dart__

```shell
pub global activate dart_enum_to_string_check
```

__Flutter__

```shell
flutter pub global active dart_enum_to_string_check
```

Then run from project folder:

__Dart__

```shell
dart_enum_to_string_check
```

__Flutter__

```shell
flutter pub global run dart_enum_to_string_check
```

#### Without pub

Download plugin to your machine and provide `bin/` location to PATH. Then run from project folder:

```shell
dart dart_enum_to_string_check.dart
```

## References

Solutions from [dart-code-metrics](https://github.com/wrike/dart-code-metrics) by [Wrike](https://github.com/wrike):
- [Files resolving in Dart Analyzer Plugin](https://github.com/fartem/dart-enum-to-string-check/blob/master/lib/src/analyzer_plugin/analyzer_plugin.dart)
- [Dart Analyzer Plugin utils](https://github.com/fartem/dart-enum-to-string-check/blob/master/lib/src/analyzer_plugin/analyzer_plugin_utils.dart)

## How to contribute

Read [Commit Convention](https://github.com/fartem/repository-rules/blob/master/commit-convention/COMMIT_CONVENTION.md). Make sure your build is green before you contribute your pull request. Then:

```shell
$ dart analyze
$ dart test
```

If you don't see any error messages, submit your pull request.

## Contributors

- [@fartem](https://github.com/fartem) as Artem Fomchenkov
