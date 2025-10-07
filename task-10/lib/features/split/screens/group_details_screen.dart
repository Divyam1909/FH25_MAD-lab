import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../core/database/database_helper.dart';
import '../models/expense_model.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Group group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late Group _group;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
  }

  Future<void> _deleteExpense(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final expenses = List<Expense>.from(_group.expenses);
      expenses.removeAt(index);
      final updatedGroup = _group.copyWith(expenses: expenses);
      await DatabaseHelper.instance.updateGroup(updatedGroup);
      setState(() => _group = updatedGroup);
    }
  }

  Future<void> _addMember() async {
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Member Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final members = List<String>.from(_group.members);
      members.add(nameController.text.trim());
      final updatedGroup = _group.copyWith(members: members);
      await DatabaseHelper.instance.updateGroup(updatedGroup);
      setState(() => _group = updatedGroup);
    }
  }

  Future<void> _removeMember(String member) async {
    // Check if member has expenses
    final hasExpenses = _group.expenses.any((e) => e.payer == member);
    
    if (hasExpenses) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Remove'),
          content: Text('$member has existing expenses. Please delete those first.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove $member from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final members = List<String>.from(_group.members);
      members.remove(member);
      if (members.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Group must have at least one member')),
          );
        }
        return;
      }
      final updatedGroup = _group.copyWith(members: members);
      await DatabaseHelper.instance.updateGroup(updatedGroup);
      setState(() => _group = updatedGroup);
    }
  }

  Future<void> _addExpense() async {
    if (_group.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add members first')),
      );
      return;
    }

    final descController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedPayer = _group.members.first;
    List<String> selectedParticipants = List<String>.from(_group.members);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedPayer,
                  decoration: const InputDecoration(
                    labelText: 'Paid by',
                    border: OutlineInputBorder(),
                  ),
                  items: _group.members
                      .map((member) => DropdownMenuItem(
                            value: member,
                            child: Text(member),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedPayer = value);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Split between:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _group.members.map((member) {
                    final isSelected = selectedParticipants.contains(member);
                    return FilterChip(
                      label: Text(member),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedParticipants.add(member);
                          } else {
                            if (selectedParticipants.length > 1) {
                              selectedParticipants.remove(member);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${((double.tryParse(amountController.text) ?? 0) / (selectedParticipants.isEmpty ? 1 : selectedParticipants.length)).toStringAsFixed(2)} per person',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true &&
        descController.text.isNotEmpty &&
        amountController.text.isNotEmpty &&
        selectedParticipants.isNotEmpty) {
      final expense = Expense(
        payer: selectedPayer!,
        amount: double.tryParse(amountController.text) ?? 0,
        description: descController.text,
        participants: selectedParticipants,
      );

      final updatedGroup = _group.copyWith(
        expenses: [..._group.expenses, expense],
      );

      await DatabaseHelper.instance.updateGroup(updatedGroup);
      setState(() => _group = updatedGroup);
    }
  }

  Future<void> _showSettlements() async {
    final settlements = _group.calculateSettlements();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settlement Summary'),
        content: settlements.isEmpty
            ? const Text('All settled up!')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: settlements
                    .map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${s.from} → ${s.to}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                '₹${s.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _exportSettlements();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportSettlements() async {
    final settlements = _group.calculateSettlements();
    final balances = _group.calculateBalances();

    // Create CSV data
    List<List<dynamic>> rows = [
      ['Group', _group.name],
      ['Total Expenses', '₹${_group.totalExpenses.toStringAsFixed(2)}'],
      [''],
      ['Individual Balances'],
      ['Member', 'Balance'],
    ];

    for (final entry in balances.entries) {
      rows.add([
        entry.key,
        '₹${entry.value.toStringAsFixed(2)}',
      ]);
    }

    rows.addAll([
      [''],
      ['Settlements'],
      ['From', 'To', 'Amount'],
    ]);

    for (final settlement in settlements) {
      rows.add([
        settlement.from,
        settlement.to,
        '₹${settlement.amount.toStringAsFixed(2)}',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    // Save to file and share
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${_group.name}_settlement.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '${_group.name} Settlement',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(_group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _addMember,
            tooltip: 'Add Member',
          ),
          IconButton(
            icon: const Icon(Icons.summarize),
            onPressed: _showSettlements,
            tooltip: 'View Settlements',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Total Expenses',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(_group.totalExpenses),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${_group.members.length} members • ${_group.expenses.length} expenses',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Members
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Members',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _group.members
                      .map((member) => Chip(
                            label: Text(member),
                            avatar: CircleAvatar(
                              child: Text(member[0].toUpperCase()),
                            ),
                            onDeleted: () => _removeMember(member),
                            deleteIcon: const Icon(Icons.close, size: 18),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Expenses List
          Expanded(
            child: _group.expenses.isEmpty
                ? const Center(
                    child: Text(
                      'No expenses yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _group.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _group.expenses[index];
                      final participants = expense.participants.isEmpty 
                          ? _group.members 
                          : expense.participants;
                      final sharePerPerson = expense.amount / participants.length;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.receipt,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(expense.description),
                          subtitle: Text(
                            'Paid by ${expense.payer} • ${DateFormat.yMMMd().format(expense.date)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currencyFormat.format(expense.amount),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () => _deleteExpense(index),
                                tooltip: 'Delete Expense',
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Split between ${participants.length} ${participants.length == 1 ? 'person' : 'people'}:',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: participants.map((p) => Chip(
                                      label: Text(p),
                                      avatar: CircleAvatar(
                                        child: Text(p[0].toUpperCase()),
                                      ),
                                    )).toList(),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${currencyFormat.format(sharePerPerson)} per person',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }
}
