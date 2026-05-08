import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MyListStatusFilter {
  all('all', 'All'),
  watching('watching', 'Watching'),
  completed('completed', 'Completed'),
  onHold('on_hold', 'On hold'),
  dropped('dropped', 'Dropped'),
  planToWatch('plan_to_watch', 'Plan to watch');

  const MyListStatusFilter(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

enum MyListViewMode {
  poster('Poster view'),
  detail('Detail view');

  const MyListViewMode(this.label);

  final String label;
}

enum MyListSortOption {
  lastUpdated('Last updated'),
  title('Title'),
  score('Score'),
  progress('Progress');

  const MyListSortOption(this.label);

  final String label;
}

final myListFilterProvider =
    StateNotifierProvider<MyListFilterNotifier, MyListStatusFilter>(
  (ref) => MyListFilterNotifier(),
);

final myListViewModeProvider =
    StateNotifierProvider<MyListViewModeNotifier, MyListViewMode>(
  (ref) => MyListViewModeNotifier(),
);

final myListSortProvider =
    StateNotifierProvider<MyListSortNotifier, MyListSortOption>(
  (ref) => MyListSortNotifier(),
);

const _myListStatusPreferenceKey = 'my_list_status_filter';
const _myListViewModePreferenceKey = 'my_list_view_mode';
const _myListSortPreferenceKey = 'my_list_sort';

MyListStatusFilter _statusFromPreference(String? value) {
  return MyListStatusFilter.values.firstWhere(
    (status) => status.name == value,
    orElse: () => MyListStatusFilter.all,
  );
}

MyListViewMode _viewModeFromPreference(String? value) {
  return MyListViewMode.values.firstWhere(
    (viewMode) => viewMode.name == value,
    orElse: () => MyListViewMode.poster,
  );
}

MyListSortOption _sortFromPreference(String? value) {
  return MyListSortOption.values.firstWhere(
    (sortOption) => sortOption.name == value,
    orElse: () => MyListSortOption.lastUpdated,
  );
}

class MyListFilterNotifier extends StateNotifier<MyListStatusFilter> {
  MyListFilterNotifier() : super(MyListStatusFilter.all) {
    _loadSavedPreference();
  }

  Future<void> _loadSavedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = _statusFromPreference(
      prefs.getString(_myListStatusPreferenceKey),
    );
  }

  Future<void> setFilter(MyListStatusFilter status) async {
    state = status;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_myListStatusPreferenceKey, status.name);
  }
}

class MyListViewModeNotifier extends StateNotifier<MyListViewMode> {
  MyListViewModeNotifier() : super(MyListViewMode.poster) {
    _loadSavedPreference();
  }

  Future<void> _loadSavedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = _viewModeFromPreference(
      prefs.getString(_myListViewModePreferenceKey),
    );
  }

  Future<void> setViewMode(MyListViewMode viewMode) async {
    state = viewMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_myListViewModePreferenceKey, viewMode.name);
  }
}

class MyListSortNotifier extends StateNotifier<MyListSortOption> {
  MyListSortNotifier() : super(MyListSortOption.lastUpdated) {
    _loadSavedPreference();
  }

  Future<void> _loadSavedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = _sortFromPreference(
      prefs.getString(_myListSortPreferenceKey),
    );
  }

  Future<void> setSort(MyListSortOption sortOption) async {
    state = sortOption;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_myListSortPreferenceKey, sortOption.name);
  }
}
