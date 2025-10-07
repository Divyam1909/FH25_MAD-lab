

import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AllTasksScreen(),
    );
  }
}
// This screen combines all three sub-task widgets.
class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // 1.1: SafeArea and AppBar are implemented here.
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Combined Widgets"),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
        // A scroll view prevents content from overflowing on small screens.
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // 1.1: Main Column for the scaffold body.
            child: Column(
              children: const [
                ProfileCard(),
                Divider(height: 40, thickness: 1),
                RatingWidget(),
                Divider(height: 40, thickness: 1),
                ContentToggle(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// --- Sub-Task 1.1: Social Media Profile Card ---
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 53,
          backgroundColor: Colors.grey.shade300,
          child: const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/profile.png'),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Divyam Navin",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Flutter Developer | Tech Enthusiast",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn("Posts", "120"),
            _buildStatColumn("Followers", "1.2M"),
            _buildStatColumn("Following", "350"),
          ],
        ),
      ],
    );
  }
  // Helper widget to build a single stat column.
  Column _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
// --- Sub-Task 1.2: Interactive Icon-Based Rating Widget ---
class RatingWidget extends StatefulWidget {
  const RatingWidget({super.key});
  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}


class _RatingWidgetState extends State<RatingWidget> {
  // 1.2: State variable to track the current rating.
  int _rating = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Rate this App", style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _rating = index + 1;
                });
              },
            );
          }),
        ),
        Text("Your Rating: $_rating", style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
// --- Sub-Task 1.3: Dynamic Content Toggle with RichText ---
class ContentToggle extends StatefulWidget {
  const ContentToggle({super.key});
  @override
  State<ContentToggle> createState() => _ContentToggleState();
}
class _ContentToggleState extends State<ContentToggle> {
  // 1.3: State variable to toggle between short and full text.
  bool _showFullText = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            children: [
              const TextSpan(text: "Flutter is an open-source UI software development kit created by Google. It is used to develop cross-platform applications"),
              if (_showFullText)
                const TextSpan(
                  text: " from a single codebase for any web browser, Fuchsia, Android, iOS, Linux, macOS, and Windows. This allows developers to write the code once and deploy it on multiple platforms, saving significant time and resources.",
                  style: TextStyle(color: Colors.black54),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          child: Text(_showFullText ? "Read Less" : "Read More"),
          onPressed: () {
            setState(() {
              _showFullText = !_showFullText;
            });
          },
        ),
      ],
    );
  }
}
