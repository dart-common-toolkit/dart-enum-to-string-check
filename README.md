# dart_enum_to_string_check

[![Travis CI](https://travis-ci.org/fartem/dart-enum-to-string-check.svg?branch=master)](https://travis-ci.org/fartem/dart-enum-to-string-check)

## About

Plugin for Dart Analyzer to checking enum.toString() usages.

## Motivation

Default Enum.toString() method represent enum constant as class name and constant name (example: `Colors.green` but not `green`). In some cases this cast is not valid for a program logic (parse values to DB or JSON) and can causing problems (when from DB you get strings without class names, `"green" == Colors.green.toString()` is not as we need). Plugin helps to prevent described problem.

## How to use

Add plugin as development dependency in `pubspec.yml`:

```yaml
dev_dependencies:

  dart_enum_to_string_check:
    git:
      url: https://github.com/fartem/dart-enum-to-string-check.git
      ref: master

```

Add plugin name to `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - dart_enum_to_string_check
```

Then restart Dart Analyzer Server.

## References

Solutions from [dart-code-metrics](https://github.com/wrike/dart-code-metrics) by [Wrike](https://github.com/wrike):
- [Files resolving in Dart Analyzer Plugin](https://github.com/fartem/dart-enum-to-string-check/blob/master/lib/src/analyzer_plugin/analyzer_plugin.dart)
- [Dart Analyzer Plugin utils](https://github.com/fartem/dart-enum-to-string-check/blob/master/lib/src/analyzer_plugin/analyzer_plugin_utils.dart)

## How to contribute

Read [Commit Convention](https://github.com/fartem/repository-rules/blob/master/commit-convention/COMMIT_CONVENTION.md). Make sure your build is green before you contribute your pull request. Then:

```shell
$ dart analyze
```

If you don't see any error messages, submit your pull request.

## Contributors

- [@fartem](https://github.com/fartem) as Artem Fomchenkov
