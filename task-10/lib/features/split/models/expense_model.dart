import 'dart:convert';
import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String payer;
  final double amount;
  final String description;
  final DateTime date;
  final List<String> participants; // Members involved in this expense

  Expense({
    String? id,
    required this.payer,
    required this.amount,
    required this.description,
    DateTime? date,
    List<String>? participants,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        participants = participants ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'payer': payer,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'participants': jsonEncode(participants),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      payer: map['payer'],
      amount: map['amount'].toDouble(),
      description: map['description'],
      date: DateTime.parse(map['date']),
      participants: map['participants'] != null
          ? List<String>.from(jsonDecode(map['participants']))
          : [],
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Expense.fromJson(Map<String, dynamic> json) => Expense.fromMap(json);
}

class Group {
  final String id;
  final String name;
  final List<String> members;
  final List<Expense> expenses;

  Group({
    String? id,
    required this.name,
    List<String>? members,
    List<Expense>? expenses,
  })  : id = id ?? const Uuid().v4(),
        members = members ?? [],
        expenses = expenses ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'members': jsonEncode(members),
      'expenses': jsonEncode(expenses.map((e) => e.toMap()).toList()),
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    final expensesData = jsonDecode(map['expenses']) as List;
    return Group(
      id: map['id'],
      name: map['name'],
      members: List<String>.from(jsonDecode(map['members'])),
      expenses: expensesData.map((e) => Expense.fromMap(e)).toList(),
    );
  }

  Group copyWith({
    String? name,
    List<String>? members,
    List<Expense>? expenses,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      members: members ?? this.members,
      expenses: expenses ?? this.expenses,
    );
  }

  // Calculate total expenses
  double get totalExpenses {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Calculate how much each member owes or is owed
  Map<String, double> calculateBalances() {
    final balances = <String, double>{};
    
    // Initialize all members with 0 balance
    for (final member in members) {
      balances[member] = 0.0;
    }

    // For each expense, calculate individual shares
    for (final expense in expenses) {
      // Determine participants for this expense
      final participants = expense.participants.isEmpty 
          ? members 
          : expense.participants;
      
      if (participants.isEmpty) continue;
      
      // Calculate share per person for this expense
      final sharePerPerson = expense.amount / participants.length;

      // Payer gets credit for what they paid
      balances[expense.payer] = (balances[expense.payer] ?? 0.0) + expense.amount;

      // Subtract what each participant should pay
      for (final participant in participants) {
        balances[participant] = (balances[participant] ?? 0.0) - sharePerPerson;
      }
    }

    return balances;
  }

  // Calculate simplified settlements (who owes whom)
  List<Settlement> calculateSettlements() {
    final balances = calculateBalances();
    final settlements = <Settlement>[];

    final debtors = balances.entries
        .where((e) => e.value < -0.01)
        .map((e) => MapEntry(e.key, -e.value))
        .toList();
    
    final creditors = balances.entries
        .where((e) => e.value > 0.01)
        .toList();

    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    int i = 0, j = 0;
    while (i < debtors.length && j < creditors.length) {
      final debtor = debtors[i];
      final creditor = creditors[j];
      
      final amount = debtor.value < creditor.value ? debtor.value : creditor.value;
      
      settlements.add(Settlement(
        from: debtor.key,
        to: creditor.key,
        amount: amount,
      ));

      debtors[i] = MapEntry(debtor.key, debtor.value - amount);
      creditors[j] = MapEntry(creditor.key, creditor.value - amount);

      if (debtors[i].value < 0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }

    return settlements;
  }
}

class Settlement {
  final String from;
  final String to;
  final double amount;

  Settlement({
    required this.from,
    required this.to,
    required this.amount,
  });

  @override
  String toString() {
    return '$from pays $to: ₹${amount.toStringAsFixed(2)}';
  }
}
