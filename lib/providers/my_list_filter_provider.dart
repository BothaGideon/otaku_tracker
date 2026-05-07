import 'package:flutter_riverpod/legacy.dart';

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

final myListFilterProvider =
    StateProvider<MyListStatusFilter>((ref) => MyListStatusFilter.all);
