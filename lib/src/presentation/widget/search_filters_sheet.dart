import 'package:flutter/material.dart';
import 'package:reading_sms/src/models/search_models.dart';

class SearchFiltersSheet extends StatefulWidget {
  final SearchFilters initialFilters;
  final Function(SearchFilters) onApply;

  const SearchFiltersSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends State<SearchFiltersSheet> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late bool? _sentOnly;
  late int? _minLength;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialFilters.startDate;
    _endDate = widget.initialFilters.endDate;
    _sentOnly = widget.initialFilters.sentOnly;
    _minLength = widget.initialFilters.minLength;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.blue),
              SizedBox(width: 12),
              Text(
                'Search Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: _clearAll,
                child: Text('Clear All'),
              ),
            ],
          ),
          Divider(height: 32),

          // Message Type Filter
          Text(
            'Message Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          SegmentedButton<bool?>(
            segments: [
              ButtonSegment(
                value: null,
                label: Text('All'),
                icon: Icon(Icons.all_inclusive, size: 18),
              ),
              ButtonSegment(
                value: false,
                label: Text('Received'),
                icon: Icon(Icons.call_received, size: 18),
              ),
              ButtonSegment(
                value: true,
                label: Text('Sent'),
                icon: Icon(Icons.call_made, size: 18),
              ),
            ],
            selected: {_sentOnly},
            onSelectionChanged: (Set<bool?> selection) {
              setState(() {
                _sentOnly = selection.first;
              });
            },
          ),
          SizedBox(height: 24),

          // Date Range Filter
          Text(
            'Date Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  context,
                  label: 'Start Date',
                  date: _startDate,
                  onSelect: (date) => setState(() => _startDate = date),
                  onClear: () => setState(() => _startDate = null),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  context,
                  label: 'End Date',
                  date: _endDate,
                  onSelect: (date) => setState(() => _endDate = date),
                  onClear: () => setState(() => _endDate = null),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Minimum Length Filter
          Text(
            'Minimum Message Length',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: (_minLength ?? 0).toDouble(),
                  min: 0,
                  max: 500,
                  divisions: 10,
                  label: _minLength == null || _minLength == 0
                      ? 'No limit'
                      : '$_minLength characters',
                  onChanged: (value) {
                    setState(() {
                      _minLength = value.toInt() == 0 ? null : value.toInt();
                    });
                  },
                ),
              ),
              SizedBox(width: 12),
              Text(
                _minLength == null || _minLength == 0 ? 'Any' : '$_minLength+',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _apply,
              icon: Icon(Icons.check),
              label: Text('Apply Filters'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildDateButton(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required Function(DateTime) onSelect,
    required VoidCallback onClear,
  }) {
    return OutlinedButton.icon(
      onPressed: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (selected != null) {
          onSelect(selected);
        }
      },
      icon: Icon(
        date == null ? Icons.calendar_today : Icons.event_available,
        size: 18,
      ),
      label: Text(
        date == null ? label : '${date.day}/${date.month}/${date.year}',
        style: TextStyle(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ).withClearButton(date != null, onClear);
  }

  void _clearAll() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _sentOnly = null;
      _minLength = null;
    });
  }

  void _apply() {
    final filters = SearchFilters(
      startDate: _startDate,
      endDate: _endDate,
      sentOnly: _sentOnly,
      minLength: _minLength,
    );
    widget.onApply(filters);
    Navigator.pop(context);
  }
}

extension _WidgetExtension on Widget {
  Widget withClearButton(bool show, VoidCallback onClear) {
    if (!show) return this;
    return Stack(
      children: [
        this,
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: onClear,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
