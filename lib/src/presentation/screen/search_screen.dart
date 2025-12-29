import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reading_sms/src/core/get_it.dart';
import 'package:reading_sms/src/core/helper/helper_fun.dart';
import 'package:reading_sms/src/core/widget/SearchWidget.dart';
import 'package:reading_sms/src/models/search_models.dart';
import 'package:reading_sms/src/presentation/cubit/search_cubit.dart';
import 'package:reading_sms/src/presentation/cubit/search_state.dart';
import 'package:reading_sms/src/presentation/screen/chat_screen.dart';
import 'package:reading_sms/src/presentation/widget/highlighted_text.dart';
import 'package:reading_sms/src/presentation/widget/search_filters_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  SearchFilters _currentFilters = const SearchFilters();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    print('Search query: $query'); // Debug print

    // Trigger UI rebuild for clear button visibility
    setState(() {});

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        context.read<SearchCubit>().search(query, filters: _currentFilters);
      } else {
        context.read<SearchCubit>().clearSearch();
      }
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFiltersSheet(
        initialFilters: _currentFilters,
        onApply: (filters) {
          setState(() {
            _currentFilters = filters;
          });
          // Re-run search with new filters
          if (_searchController.text.trim().isNotEmpty) {
            context.read<SearchCubit>().search(
              _searchController.text,
              filters: filters,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Messages'),
        forceMaterialTransparency: true,
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return Column(
            children: [
              // Search Bar with Filters
              SearchWidget(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: _onSearchChanged,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchCubit>().clearSearch();
                        },
                      )
                    : null,
              ),

              // Active Filters Chips
              _buildActiveFilters(),

              // Search Results
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return _buildInitialView(context);
                    } else if (state is SearchLoading) {
                      return _buildLoadingView();
                    } else if (state is SearchLoaded) {
                      return _buildResultsView(state);
                    } else if (state is SearchError) {
                      return _buildErrorView(state);
                    }
                    return SizedBox();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveFilters() {
    if (!_currentFilters.hasFilters) return SizedBox();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_currentFilters.sentOnly != null)
            _buildFilterChip(
              label: _currentFilters.sentOnly! ? 'Sent' : 'Received',
              icon: _currentFilters.sentOnly!
                  ? Icons.call_made
                  : Icons.call_received,
              onDelete: () {
                setState(() {
                  _currentFilters = _currentFilters.copyWith(
                    clearSentOnly: true,
                  );
                });
              },
            ),
          if (_currentFilters.startDate != null)
            _buildFilterChip(
              label:
                  'From ${_currentFilters.startDate!.day}/${_currentFilters.startDate!.month}',
              icon: Icons.date_range,
              onDelete: () {
                setState(() {
                  _currentFilters = _currentFilters.copyWith(
                    clearStartDate: true,
                  );
                });
              },
            ),
          if (_currentFilters.endDate != null)
            _buildFilterChip(
              label:
                  'To ${_currentFilters.endDate!.day}/${_currentFilters.endDate!.month}',
              icon: Icons.date_range,
              onDelete: () {
                setState(() {
                  _currentFilters = _currentFilters.copyWith(
                    clearEndDate: true,
                  );
                });
              },
            ),
          if (_currentFilters.minLength != null)
            _buildFilterChip(
              label: 'Min ${_currentFilters.minLength}+ chars',
              icon: Icons.text_fields,
              onDelete: () {
                setState(() {
                  _currentFilters = _currentFilters.copyWith(
                    clearMinLength: true,
                  );
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onDelete,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: TextStyle(fontSize: 12)),
      onDeleted: onDelete,
      deleteIcon: Icon(Icons.close, size: 16),
      backgroundColor: Colors.blue.withOpacity(0.1),
      side: BorderSide(color: Colors.blue, width: 1),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    final history = cubit.searchHistory;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Tips
              _buildTipCard(
                icon: Icons.lightbulb_outline,
                title: 'Search Tips',
                tips: [
                  'Search by contact name',
                  'Search by phone number',
                  'Results show one contact per match',
                  'Recent searches are saved for quick access',
                ],
              ),
              SizedBox(height: 24),

              // Search History
              if (history.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        cubit.clearHistory();
                      },
                      child: Text('Clear'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ...history.map((item) => _buildHistoryItem(context, item)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required List<String> tips,
  }) {
    return Card(
      elevation: 0,
      color: Colors.blue.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...tips.map(
              (tip) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 18, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, SearchHistoryItem item) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.history, size: 20, color: Colors.grey[700]),
      ),
      title: Text(item.query),
      subtitle: Text(
        '${item.resultCount} result${item.resultCount != 1 ? 's' : ''} • ${_formatHistoryDate(item.timestamp)}',
        style: TextStyle(fontSize: 12),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _searchController.text = item.query;
        context.read<SearchCubit>().search(
          item.query,
          filters: _currentFilters,
        );
      },
    );
  }

  String _formatHistoryDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Searching through messages...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(SearchLoaded state) {
    if (!state.hasResults) {
      return _buildNoResults();
    }

    return Column(
      children: [
        // Results Summary
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.blue.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.blue, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Found ${state.totalResults} contact${state.totalResults != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Matching your search',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Results List
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: state.results.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final result = state.results[index];
              return _buildResultItem(result, state.query);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(SearchResult result, String query) {
    final conversation = result.conversation;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Icon(
          Icons.person,
          color: Colors.blue,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: HighlightedText(
              text: conversation.displayName,
              query: query,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              defaultStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.blueGrey
              ),
              highlightStyle: TextStyle(
                backgroundColor: Colors.yellow.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            formatDate(conversation.lastDate),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text(
          conversation.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
      ),
      trailing: conversation.messageCount > 0
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${conversation.messageCount}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              phoneNumber: conversation.phoneNumber,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No messages found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(SearchError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

