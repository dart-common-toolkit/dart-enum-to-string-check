import 'filter_period.dart';
import 'settings_manager.dart';

class InvalidSettings {
  final SettingsManager settingsManager;

  const InvalidSettings(this.settingsManager);

  HistoryFilter restoreHistoryFilter() {
    final filter = settingsManager.getString('history_filter') ?? 'all';
    final filterPeriod = FilterPeriod.values.firstWhere((value) => value.toString() == filter);
    return HistoryFilter(filterPeriod);
  }
}
