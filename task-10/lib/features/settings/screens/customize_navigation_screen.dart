import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/navigation_provider.dart';

class CustomizeNavigationScreen extends StatefulWidget {
  const CustomizeNavigationScreen({super.key});

  @override
  State<CustomizeNavigationScreen> createState() =>
      _CustomizeNavigationScreenState();
}

class _CustomizeNavigationScreenState extends State<CustomizeNavigationScreen> {
  late List<NavItem> _selectedItems;

  @override
  void initState() {
    super.initState();
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    _selectedItems = List.from(navProvider.navItems);
  }

  void _toggleItem(NavItem item) {
    setState(() {
      if (item.id == 'home') {
        // Home cannot be removed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Home is required and cannot be removed'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        if (_selectedItems.length >= 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 4 items allowed in navigation bar'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        _selectedItems.add(item);
      }
    });
  }

  void _saveAndExit() async {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    await navProvider.updateNavItems(_selectedItems);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Navigation updated! Changes will take effect immediately.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableItems = NavigationProvider.allFeatures
        .where((item) => !_selectedItems.contains(item))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Navigation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAndExit,
            tooltip: 'Save',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Customize Your Navigation Bar',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select up to 4 features for quick access. Home is always included.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Selected Items
          Text(
            'In Navigation Bar (${_selectedItems.length}/4)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (_selectedItems.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No items selected',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex == 0 || newIndex == 0) {
                    // Home must stay first
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Home must remain in first position'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _selectedItems.removeAt(oldIndex);
                  _selectedItems.insert(newIndex, item);
                });
              },
              children: _selectedItems.map((item) {
                final isHome = item.id == 'home';
                return Card(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isHome ? theme.colorScheme.primaryContainer : null,
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.drag_handle),
                        const SizedBox(width: 8),
                        Icon(item.selectedIcon),
                      ],
                    ),
                    title: Text(item.label),
                    subtitle: isHome ? const Text('Required') : null,
                    trailing: isHome
                        ? Icon(Icons.lock, color: theme.colorScheme.primary)
                        : IconButton(
                            icon: const Icon(Icons.remove_circle),
                            color: Colors.red,
                            onPressed: () => _toggleItem(item),
                          ),
                  ),
                );
              }).toList(),
            ),
          
          const SizedBox(height: 24),
          
          // Available Items
          Text(
            'Available Features',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (availableItems.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'All features are in your navigation bar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            ...availableItems.map((item) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(item.selectedIcon),
                    title: Text(item.label),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: _selectedItems.length >= 4
                            ? Colors.grey
                            : Colors.green,
                      ),
                      onPressed: _selectedItems.length >= 4
                          ? null
                          : () => _toggleItem(item),
                    ),
                  ),
                )),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: _saveAndExit,
          icon: const Icon(Icons.save),
          label: const Text('Save & Apply'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}

