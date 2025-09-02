import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MADLabApp());
}

/// Root App
class MADLabApp extends StatelessWidget {
  const MADLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAD Lab Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        snackBarTheme:
            const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      ),
      home: const HomePage(),
    );
  }
}

/// App Shell with 3 main tabs (Tasks 1–3)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _tabIndex = 0;

  final List<Widget> _pages = const [
    WidgetsDemo(), // TASK 1
    FormsDemo(), // TASK 2
    LayoutsDemo(), // TASK 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _pages[_tabIndex],
      ),
      // === TASK 3.3: Custom Bottom Navigation Bar with Animated Layouts ===
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (i) {
              final selected = i == _tabIndex;
              final icon = [Icons.widgets, Icons.list_alt, Icons.dashboard][i];
              final label = ['Widgets', 'Forms', 'Layouts'][i];

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _tabIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon,
                          size: selected ? 26 : 22,
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: selected ? 14 : 12,
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        child: Text(label),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// TASK 1: USING COMMON WIDGETS & APPLYING GESTURES
/// Sub-tasks: 1.1 Profile Card, 1.2 Rating, 1.3 RichText Toggle,
///            + (EXTRA) Draggable + DragTarget demo (explicitly required)
///////////////////////////////////////////////////////////////////////////////
class WidgetsDemo extends StatelessWidget {
  const WidgetsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // <- SafeArea per requirement
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task 1: Widgets & Gestures'),
          actions: [
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  builder: (_) => const _SettingsSheet(),
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _SectionTitle('1.1 Social Media Profile Card'),
            ProfileCard(),
            SizedBox(height: 24),
            _SectionTitle(
                '1.2 Interactive Icon-Based Rating (with persistence)'),
            RatingWidget(),
            SizedBox(height: 24),
            _SectionTitle('1.3 Dynamic Content Toggle with RichText'),
            RichTextToggle(),
            SizedBox(height: 24),
            _SectionTitle('Extra: Draggable → DragTarget (Favorites / Trash)'),
            DragDropDemo(),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w700));
  }
}

/// === Sub-Task 1.1: Social Media Profile Card ===
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Divyam Navin',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                        Text('Flutter • UI/UX • Open Source',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.white70)),
                      ],
                    ),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Followed!')),
                      ),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Follow'),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Building beautiful cross-platform apps with Flutter. Coffee, code, and clean design.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black87),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _Metric(label: 'Posts', value: '128'),
                _Metric(label: 'Followers', value: '2.8k'),
                _Metric(label: 'Following', value: '312'),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Message')),
              TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share')),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.black54)),
      ],
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Theme'),
          subtitle: const Text('Uses Material 3 dynamic color'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'MAD Lab Flutter',
              applicationVersion: '1.1.0',
              applicationIcon: const FlutterLogo(),
            );
          },
        ),
      ],
    );
  }
}

/// === Sub-Task 1.2: Interactive Icon-Based Rating Widget (persisted) ===
class RatingWidget extends StatefulWidget {
  const RatingWidget({super.key});

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int _rating = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rating = prefs.getInt('rating') ?? 0;
      _loading = false;
    });
  }

  Future<void> _saveRating(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rating', value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: CircularProgressIndicator(),
      ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Wrap(
              spacing: 4,
              children: List.generate(5, (index) {
                final filled = index < _rating;
                return IconButton(
                  tooltip: 'Rate ${index + 1}',
                  icon: Icon(filled ? Icons.star : Icons.star_border),
                  color: Colors.amber,
                  onPressed: () {
                    setState(() => _rating = index + 1);
                    _saveRating(index + 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Thanks! You rated $_rating/5')),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 4),
            Text('Current Rating: $_rating / 5',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// === Sub-Task 1.3: Dynamic Content Toggle with RichText ===
class RichTextToggle extends StatefulWidget {
  const RichTextToggle({super.key});
  @override
  State<RichTextToggle> createState() => _RichTextToggleState();
}

class _RichTextToggleState extends State<RichTextToggle> {
  bool _showFullText = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  const TextSpan(
                    text:
                        'Flutter lets you build for mobile, web, and desktop. ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (_showFullText)
                    const TextSpan(
                      text:
                          'With a composable widget tree, performant rendering, and a vibrant ecosystem, you can ship delightful UIs rapidly.',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _showFullText = !_showFullText),
              icon: Icon(_showFullText ? Icons.expand_less : Icons.expand_more),
              label: Text(_showFullText ? 'Read Less' : 'Read More'),
            ),
          ],
        ),
      ),
    );
  }
}

/// === EXTRA under Task 1: Draggable + DragTarget demo ===
class DragDropDemo extends StatefulWidget {
  const DragDropDemo({super.key});
  @override
  State<DragDropDemo> createState() => _DragDropDemoState();
}

class _DragDropDemoState extends State<DragDropDemo> {
  final items = ['🔥', '⭐', '🎵', '📌', '💡'];
  final favorites = <String>[];
  final trash = <String>[];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((e) => Draggable<String>(
                    data: e,
                    feedback: _Chip(e, elevated: true),
                    childWhenDragging: Opacity(opacity: .3, child: _Chip(e)),
                    child: _Chip(e),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DragTarget<String>(
                onAccept: (data) => setState(() {
                  if (!favorites.contains(data)) favorites.add(data);
                }),
                builder: (_, __, isOver) => _DropZone(
                  title: 'Favorites',
                  subtitle: '${favorites.length} item(s)',
                  isOver: isOver.isNotEmpty,
                  icon: Icons.favorite,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DragTarget<String>(
                onAccept: (data) => setState(() {
                  trash.add(data);
                }),
                builder: (_, __, isOver) => _DropZone(
                  title: 'Trash',
                  subtitle: '${trash.length} item(s)',
                  isOver: isOver.isNotEmpty,
                  icon: Icons.delete,
                ),
              ),
            ),
          ],
        ),
        if (favorites.isNotEmpty || trash.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Favorites: ${favorites.join(" ")}'),
          Text('Trash: ${trash.join(" ")}'),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool elevated;
  const _Chip(this.label, {this.elevated = false});
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevated ? 4 : 0,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

class _DropZone extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isOver;
  final IconData icon;
  const _DropZone({
    required this.title,
    required this.subtitle,
    required this.isOver,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(16),
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(
          color: isOver
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 28,
              color: isOver ? Theme.of(context).colorScheme.primary : null),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// TASK 2: INTERACTIVE FORMS
/// Sub-tasks: 2.1 Multi-Step Registration, 2.2 Dynamic Field Add/Remove,
///            2.3 Form with DatePicker (intl)
///////////////////////////////////////////////////////////////////////////////
class FormsDemo extends StatelessWidget {
  const FormsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Task 2: Forms')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _SectionTitle('2.1 Multi-Step Registration Form with Validation'),
            MultiStepForm(),
            SizedBox(height: 24),
            _SectionTitle('2.2 Dynamic Form Field Addition / Removal'),
            DynamicFormFields(),
            SizedBox(height: 24),
            _SectionTitle('2.3 Form with Non-Traditional Input (Date Picker)'),
            DatePickerForm(),
          ],
        ),
      ),
    );
  }
}

/// === Sub-Task 2.1: Multi-Step Registration Form ===
class MultiStepForm extends StatefulWidget {
  const MultiStepForm({super.key});

  @override
  State<MultiStepForm> createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  final _formKey = GlobalKey<FormState>();
  int _step = 1;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _step == 1
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) {
                    final regex = RegExp(r'^\S+@\S+\.\S+$');
                    if (v == null || v.isEmpty) return 'Email required';
                    if (!regex.hasMatch(v)) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline)),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        setState(() => _step = 2);
                      }
                    },
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
            secondChild: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_android)),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Phone required';
                    if (!RegExp(r'^\d{10}$').hasMatch(v))
                      return 'Enter 10 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => setState(() => _step = 1),
                      child: const Text('Back'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Submit'),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Registration Successful'),
                              content: Text('Welcome, ${_name.text}!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Form submitted successfully!')),
                                    );
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
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

/// === Sub-Task 2.2: Dynamic Form Field Add/Remove ===
class DynamicFormFields extends StatefulWidget {
  const DynamicFormFields({super.key});

  @override
  State<DynamicFormFields> createState() => _DynamicFormFieldsState();
}

class _DynamicFormFieldsState extends State<DynamicFormFields> {
  final _controllers = <TextEditingController>[];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addTextField() {
    setState(() => _controllers.add(TextEditingController()));
  }

  void _removeTextField(int index) {
    setState(() => _controllers.removeAt(index).dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: _controllers.length,
              itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: TextFormField(
                  controller: _controllers[index],
                  decoration:
                      const InputDecoration(hintText: 'Enter something...'),
                ),
                trailing: IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeTextField(index),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _addTextField,
                icon: const Icon(Icons.add),
                label: const Text('Add Field'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// === Sub-Task 2.3: Form with Date Picker (intl) ===
class DatePickerForm extends StatefulWidget {
  const DatePickerForm({super.key});

  @override
  State<DatePickerForm> createState() => _DatePickerFormState();
}

class _DatePickerFormState extends State<DatePickerForm> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select Date of Birth',
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _selectedDate == null
        ? 'Select Date of Birth'
        : DateFormat.yMMMd().format(_selectedDate!);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Name', prefixIcon: Icon(Icons.badge_outlined)),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(formatted),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter your name')),
                  );
                  return;
                }
                if (_selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select your date of birth')),
                  );
                  return;
                }
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Submitted'),
                    content: Text(
                      'Name: ${_nameController.text}\nDOB: ${DateFormat.yMMMMd().format(_selectedDate!)}',
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK')),
                    ],
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// TASK 3: LAYOUTS & GESTURES
/// Sub-tasks: 3.1 Spotify Album Page, 3.2 Draggable & Resizable Note,
///            3.3 Custom Bottom Nav (already implemented in HomePage)
///////////////////////////////////////////////////////////////////////////////
class LayoutsDemo extends StatelessWidget {
  const LayoutsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Task 3: Layouts & Gestures'),
            bottom: const TabBar(
              tabs: [
                Tab(text: '3.1 Spotify UI'),
                Tab(text: '3.2 Notes'),
                Tab(text: '3.3 Animated Nav'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              SpotifyUI(),
              DraggableNotesDemo(),
              AnimatedNavDemo(), // mirrors bottom bar pattern with page switch
            ],
          ),
        ),
      ),
    );
  }
}

/// === Sub-Task 3.1: Spotify-like Album Page (Stack, overlay, controls) ===
class SpotifyUI extends StatefulWidget {
  const SpotifyUI({super.key});
  @override
  State<SpotifyUI> createState() => _SpotifyUIState();
}

class _SpotifyUIState extends State<SpotifyUI> {
  int? _playingIndex;

  @override
  Widget build(BuildContext context) {
    final songs = List.generate(12, (i) => 'Track ${i + 1}');
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/album.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.6)),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/album.jpg', height: 220),
                ),
              ),
              const Text('Focus & Flow',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Various Artists',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.shuffle, color: Colors.white)),
                  IconButton(
                      onPressed: () {},
                      icon:
                          const Icon(Icons.skip_previous, color: Colors.white)),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.skip_next, color: Colors.white)),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.repeat, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: songs.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Colors.white24),
                itemBuilder: (context, index) {
                  final playing = _playingIndex == index;
                  return ListTile(
                    key: ValueKey(index),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: Icon(
                      playing ? Icons.equalizer : Icons.music_note,
                      color: playing ? Colors.greenAccent : Colors.white,
                    ),
                    title: Text(
                      songs[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: playing ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text('3:45',
                        style: TextStyle(color: Colors.white54)),
                    trailing: IconButton(
                      icon: Icon(
                          playing ? Icons.pause_circle : Icons.play_circle_fill,
                          color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _playingIndex = playing ? null : index;
                        });
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

/// === Sub-Task 3.2: Draggable & Resizable Note Widget (with bounds & delete) ===
class DraggableNotesDemo extends StatefulWidget {
  const DraggableNotesDemo({super.key});

  @override
  State<DraggableNotesDemo> createState() => _DraggableNotesDemoState();
}

class _DraggableNotesDemoState extends State<DraggableNotesDemo> {
  final List<NoteWidget> _notes = [];

  void _addNote() => setState(() => _notes.add(NoteWidget(
        key: UniqueKey(),
        initial: Offset(60 + 20.0 * _notes.length, 120 + 20.0 * _notes.length),
      )));

  void _removeNote(Key key) =>
      setState(() => _notes.removeWhere((n) => n.key == key));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (_, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              ..._notes.map((n) => NoteWidget(
                    key: n.key,
                    initial: (n.initial ?? const Offset(100, 100)),
                    onDelete: () => _removeNote(n.key!),
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  )),
              Positioned(
                bottom: 24,
                right: 24,
                child: Opacity(
                  opacity: .25,
                  child: Icon(Icons.touch_app,
                      size: 42, color: Colors.grey.shade700),
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNote,
        icon: const Icon(Icons.note_add),
        label: const Text('Add Note'),
      ),
    );
  }
}

class NoteWidget extends StatefulWidget {
  final Offset? initial;
  final VoidCallback? onDelete;
  final double? maxWidth;
  final double? maxHeight;

  const NoteWidget({
    super.key,
    this.initial,
    this.onDelete,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  State<NoteWidget> createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  late Offset position;
  double scale = 1.0;

  @override
  void initState() {
    super.initState();
    position = widget.initial ?? const Offset(100, 100);
  }

  @override
  Widget build(BuildContext context) {
    final noteSize = 160.0 * scale;
    final maxX = (widget.maxWidth ?? 400) - noteSize;
    final maxY = (widget.maxHeight ?? 800) - noteSize;

    void clamp() {
      position = Offset(
        position.dx.clamp(0, math.max(0.0, maxX)),
        position.dy.clamp(0, math.max(0.0, maxY)),
      );
    }

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() {
          position += d.delta;
          clamp();
        }),
        onScaleUpdate: (d) => setState(() {
          scale = (d.scale).clamp(0.6, 1.8);
          clamp();
        }),
        onLongPress: () {
          showMenu(
            context: context,
            position:
                RelativeRect.fromLTRB(position.dx + 20, position.dy + 20, 0, 0),
            items: [
              PopupMenuItem(
                child: const ListTile(
                    leading: Icon(Icons.delete_outline), title: Text('Delete')),
                onTap: widget.onDelete,
              ),
            ],
          );
        },
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.yellow.shade200,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    blurRadius: 6, offset: Offset(0, 3), color: Colors.black26)
              ],
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Drag me.\nPinch to resize.\nLong press for options.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// === Sub-Task 3.3 mirror: Page bodies for AnimatedSwitcher demo ===
class AnimatedNavDemo extends StatefulWidget {
  const AnimatedNavDemo({super.key});
  @override
  State<AnimatedNavDemo> createState() => _AnimatedNavDemoState();
}

class _AnimatedNavDemoState extends State<AnimatedNavDemo> {
  int index = 0;
  final pages = const [
    _DemoPage(color: Colors.teal, text: 'Home Page'),
    _DemoPage(color: Colors.deepPurple, text: 'Search Page'),
    _DemoPage(color: Colors.orange, text: 'Profile Page'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: pages[index],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (i) {
            final selected = index == i;
            final icon = [Icons.home, Icons.search, Icons.person][i];
            final label = ['Home', 'Search', 'Profile'][i];
            return GestureDetector(
              onTap: () => setState(() => index = i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: selected ? 28 : 22,
                      color: selected ? Colors.blue : Colors.grey),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: selected ? Colors.blue : Colors.grey,
                      fontSize: selected ? 15 : 12,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DemoPage extends StatelessWidget {
  final Color color;
  final String text;
  const _DemoPage({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(text),
      width: 260,
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
