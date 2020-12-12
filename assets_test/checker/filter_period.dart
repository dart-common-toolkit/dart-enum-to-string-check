enum FilterPeriod {
  all,
  today,
  yesterday,
  lastWeek,
  lastMonth,
  lastYear,
}

class HistoryFilter {
  final FilterPeriod filterPeriod;

  const HistoryFilter(this.filterPeriod);
}
