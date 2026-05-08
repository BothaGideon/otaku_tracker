import 'package:flutter/material.dart';
import 'package:otaku_tracker/providers/my_list/my_list_filter_provider.dart';

class MyListControlsBar extends StatelessWidget {
  final MyListStatusFilter selectedStatus;
  final MyListSortOption selectedSort;
  final MyListViewMode selectedViewMode;
  final Future<void> Function(MyListControlsSelection selection) onApply;

  const MyListControlsBar({
    super.key,
    required this.selectedStatus,
    required this.selectedSort,
    required this.selectedViewMode,
    required this.onApply,
  });

  String _summaryText() {
    return '${selectedStatus.label} • ${selectedSort.label} • ${selectedViewMode.label}';
  }

  Future<void> _openControlsSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => MyListControlsSheet(
        initialStatus: selectedStatus,
        initialSort: selectedSort,
        initialViewMode: selectedViewMode,
        onApply: onApply,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected filters',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  _summaryText(),
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonalIcon(
            onPressed: () => _openControlsSheet(context),
            icon: const Icon(Icons.tune),
            label: const Text('Filter & sort'),
          ),
        ],
      ),
    );
  }
}

class MyListControlsSheet extends StatefulWidget {
  final MyListStatusFilter initialStatus;
  final MyListSortOption initialSort;
  final MyListViewMode initialViewMode;
  final Future<void> Function(MyListControlsSelection selection) onApply;

  const MyListControlsSheet({
    super.key,
    required this.initialStatus,
    required this.initialSort,
    required this.initialViewMode,
    required this.onApply,
  });

  @override
  State<MyListControlsSheet> createState() => _MyListControlsSheetState();
}

class _MyListControlsSheetState extends State<MyListControlsSheet> {
  late MyListStatusFilter selectedStatus;
  late MyListSortOption selectedSort;
  late MyListViewMode selectedViewMode;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.initialStatus;
    selectedSort = widget.initialSort;
    selectedViewMode = widget.initialViewMode;
  }

  void _resetToDefaults() {
    setState(() {
      selectedStatus = MyListStatusFilter.all;
      selectedSort = MyListSortOption.lastUpdated;
      selectedViewMode = MyListViewMode.poster;
    });
  }

  Future<void> _apply() async {
    await widget.onApply(
      MyListControlsSelection(
        status: selectedStatus,
        sort: selectedSort,
        viewMode: selectedViewMode,
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'List controls',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MyListStatusFilter.values
                      .map(
                        (status) => ChoiceChip(
                          label: Text(status.label),
                          selected: selectedStatus == status,
                          showCheckmark: false,
                          onSelected: (_) {
                            setState(() {
                              selectedStatus = status;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sort',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MyListSortOption.values
                      .map(
                        (sortOption) => ChoiceChip(
                          label: Text(sortOption.label),
                          selected: selectedSort == sortOption,
                          showCheckmark: false,
                          onSelected: (_) {
                            setState(() {
                              selectedSort = sortOption;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'View',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SegmentedButton<MyListViewMode>(
                  segments: MyListViewMode.values
                      .map(
                        (viewMode) => ButtonSegment<MyListViewMode>(
                          value: viewMode,
                          label: Text(viewMode.label),
                        ),
                      )
                      .toList(),
                  selected: {selectedViewMode},
                  onSelectionChanged: (selection) {
                    if (selection.isNotEmpty) {
                      setState(() {
                        selectedViewMode = selection.first;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetToDefaults,
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _apply,
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyListControlsSelection {
  final MyListStatusFilter status;
  final MyListSortOption sort;
  final MyListViewMode viewMode;

  const MyListControlsSelection({
    required this.status,
    required this.sort,
    required this.viewMode,
  });
}
