import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../models/deadline_model.dart';
import '../widgets/deadline_card.dart';
import 'deadline_edit_screen.dart';

class DeadlinesListScreen extends StatefulWidget {
  const DeadlinesListScreen({super.key});

  @override
  State<DeadlinesListScreen> createState() => _DeadlinesListScreenState();
}

class _DeadlinesListScreenState extends State<DeadlinesListScreen> {
  List<Deadline> _allDeadlines = [];
  List<Deadline> _filteredDeadlines = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Priority? _filterPriority;
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    _refreshDeadlines();
  }

  Future<void> _refreshDeadlines() async {
    setState(() => _isLoading = true);
    final deadlines = await DatabaseHelper.instance.readAllDeadlines();
    setState(() {
      _allDeadlines = deadlines;
      _filterDeadlines();
      _isLoading = false;
    });
  }

  void _filterDeadlines() {
    _filteredDeadlines = _allDeadlines.where((deadline) {
      final matchesSearch = _searchQuery.isEmpty ||
          deadline.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          deadline.subject.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesPriority = _filterPriority == null || deadline.priority == _filterPriority;
      final matchesCompleted = _showCompleted || !deadline.completed;

      return matchesSearch && matchesPriority && matchesCompleted;
    }).toList();
  }

  void _navigateAndRefresh(BuildContext context, {Deadline? deadline}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeadlineEditScreen(deadline: deadline)),
    );
    _refreshDeadlines();
  }

  void _deleteDeadline(String id) async {
    await DatabaseHelper.instance.deleteDeadline(id);
    _refreshDeadlines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deadline Radar'),
        actions: [
          PopupMenuButton<Priority?>(
            icon: Icon(_filterPriority != null ? Icons.filter_list : Icons.filter_list_outlined),
            tooltip: 'Filter by Priority',
            onSelected: (priority) {
              setState(() {
                _filterPriority = _filterPriority == priority ? null : priority;
                _filterDeadlines();
              });
            },
            itemBuilder: (context) => [
              if (_filterPriority != null)
                const PopupMenuItem(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.clear),
                      SizedBox(width: 8),
                      Text('Clear Filter'),
                    ],
                  ),
                ),
              ...Priority.values.map((priority) => PopupMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        if (_filterPriority == priority)
                          const Icon(Icons.check, size: 18)
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: priority == Priority.high
                              ? Colors.red
                              : priority == Priority.medium
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(priority.name.toUpperCase()),
                      ],
                    ),
                  )),
            ],
          ),
          IconButton(
            icon: Icon(_showCompleted ? Icons.visibility : Icons.visibility_off),
            tooltip: _showCompleted ? 'Hide Completed' : 'Show Completed',
            onPressed: () {
              setState(() {
                _showCompleted = !_showCompleted;
                _filterDeadlines();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search deadlines...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _filterDeadlines();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterDeadlines();
                });
              },
            ),
          ),
          // Filter Chips
          if (_filterPriority != null || !_showCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_filterPriority != null)
                    Chip(
                      label: Text('Priority: ${_filterPriority!.name.toUpperCase()}'),
                      onDeleted: () {
                        setState(() {
                          _filterPriority = null;
                          _filterDeadlines();
                        });
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                    ),
                  if (!_showCompleted)
                    Chip(
                      label: const Text('Hide Completed'),
                      onDeleted: () {
                        setState(() {
                          _showCompleted = true;
                          _filterDeadlines();
                        });
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                    ),
                ],
              ),
            ),
          // Deadlines List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allDeadlines.isEmpty
                    ? const Center(child: Text('No deadlines set. Add one!'))
                    : _filteredDeadlines.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  'No deadlines found',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _filterPriority = null;
                                      _showCompleted = true;
                                      _filterDeadlines();
                                    });
                                  },
                                  child: const Text('Clear filters'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _refreshDeadlines,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: _filteredDeadlines.length,
                              itemBuilder: (context, index) {
                                final deadline = _filteredDeadlines[index];
                                return DeadlineCard(
                                  deadline: deadline,
                                  onTap: () => _navigateAndRefresh(context, deadline: deadline),
                                  onDelete: () => _deleteDeadline(deadline.id),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}