import 'filter_period.dart';
import 'settings_manager.dart';

class ValidSettings {
  final SettingsManager settingsManager;

  const ValidSettings(this.settingsManager);

  HistoryFilter restoreHistoryFilter() {
    final filter = settingsManager.getString('history_filter') ?? 'all';
    final filterPeriod = FilterPeriod.values.firstWhere((value) => _enumToString(value) == filter);
    return HistoryFilter(filterPeriod);
  }

  // ignore: avoid_annotating_with_dynamic
  String _enumToString(dynamic enumValue) => enumValue.toString().split('.').last;
}
