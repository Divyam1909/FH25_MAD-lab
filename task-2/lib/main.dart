import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Removes the debug banner.
      debugShowCheckedModeBanner: false,
      home: InstantDisplayScreen(),
    );
  }
}
// We use a StatefulWidget because the screen's content needs to change.
class InstantDisplayScreen extends StatefulWidget {
  const InstantDisplayScreen({super.key});
  @override
  State<InstantDisplayScreen> createState() => _InstantDisplayScreenState();
}
class _InstantDisplayScreenState extends State<InstantDisplayScreen> {
  // This variable will store the text from the text box.
  String _currentText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Text Display'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The TextField for user input.
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Type something...',
              ),
              // This function runs every time the text changes.
              onChanged: (newText) {
                // setState tells Flutter to redraw the screen with new i/p
                setState(() {
                  _currentText = newText;
                });
              },
            ),
            const SizedBox(height: 20),
            // This Text widget displays the stored text.
            Text(
              _currentText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
