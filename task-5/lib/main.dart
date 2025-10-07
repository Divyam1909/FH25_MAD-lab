import 'package:flutter/material.dart';
import 'dart:math';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainScreen(),
    );
  }
}


// --- Sub-Task 3.3: Main screen with custom animated navigation ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});


  @override
  State<MainScreen> createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;


  final List<Widget> _pages = const [
    SpotifyScreen(key: ValueKey(0)),
    DraggableNotesScreen(key: ValueKey(1)),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: _buildCustomBottomBar(),
    );
  }


  Widget _buildCustomBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.music_note, "Listen Now", 0),
          _buildNavItem(Icons.edit_note, "Notes", 1),
        ],
      ),
    );
  }


  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.greenAccent : Colors.grey),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Text(
              label,
              style: TextStyle(
                fontSize: isSelected ? 12 : 10,
                color: isSelected ? Colors.greenAccent : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          )
        ],
      ),
    );
  }
}




// --- Sub-Task 3.1: Spotify Album Page UI ---
class SpotifyScreen extends StatelessWidget {
  const SpotifyScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Now Playing'),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://picsum.photos/id/1018/800',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: kToolbarHeight + 40),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black26,
                  child: Image.network('https://picsum.photos/id/1018/400', height: 250),
                ),
                const SizedBox(height: 20),
                const Text('Mountain Sunrise', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('By Nature Sounds', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 20),
               
                // ================== FIX IS HERE ==================
                // Removed the 'const' keyword from this Row.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    IconButton(icon: Icon(Icons.shuffle), onPressed: null),
                    IconButton(icon: Icon(Icons.skip_previous), onPressed: null),
                    IconButton(icon: Icon(Icons.play_circle_fill, size: 60), onPressed: null),
                    IconButton(icon: Icon(Icons.skip_next), onPressed: null),
                    IconButton(icon: Icon(Icons.repeat), onPressed: null),
                  ],
                ),
                // ================ END OF FIX ================


                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 8,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white24),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text('${index + 1}'),
                      title: Text('Track ${index + 1}'),
                      trailing: const Icon(Icons.more_vert),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}




// --- Sub-Task 3.2: Draggable and Resizable Note Widget (Corrected) ---
class DraggableNotesScreen extends StatefulWidget {
  const DraggableNotesScreen({super.key});


  @override
  State<DraggableNotesScreen> createState() => _DraggableNotesScreenState();
}


class _DraggableNotesScreenState extends State<DraggableNotesScreen> {
  final List<Widget> _notes = [];


  // Function to add a new note at a slightly random position.
  void _addNote() {
    setState(() {
      final random = Random();
      final initialOffset = Offset(
        50.0 + random.nextDouble() * 150,
        50.0 + random.nextDouble() * 200,
      );
      _notes.add(DraggableNote(key: UniqueKey(), initialOffset: initialOffset));
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draggable Notes')),
      body: Stack(children: _notes),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}


class DraggableNote extends StatefulWidget {
  final Offset initialOffset;
  const DraggableNote({super.key, this.initialOffset = Offset.zero});


  @override
  State<DraggableNote> createState() => _DraggableNoteState();
}


class _DraggableNoteState extends State<DraggableNote> {
  // Controller to manage the text inside the note.
  final TextEditingController _textController = TextEditingController();


  late Offset _offset;
  double _scale = 1.0;
  late Offset _startDragOffset;
  late double _startScale;


  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
  }


  @override
  void dispose() {
    // Clean up the controller when the widget is removed.
    _textController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onScaleStart: (details) {
          _startDragOffset = details.focalPoint;
          _startScale = _scale;
        },
        onScaleUpdate: (details) {
          setState(() {
            final dragDelta = details.focalPoint - _startDragOffset;
            _offset += dragDelta;
            _startDragOffset = details.focalPoint;
            _scale = (_startScale * details.scale).clamp(0.5, 3.0);
          });
        },
        child: Transform.scale(
          scale: _scale,
          child: Container(
            width: 150,
            height: 150,
            padding: const EdgeInsets.all(8.0), // Padding for the text field
            decoration: BoxDecoration(
              color: Colors.yellow.shade200,
              boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
            ),
            // Replace the static Text widget with an editable TextField.
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Your note...',
                border: InputBorder.none, // Removes the underline
              ),
              maxLines: null, // Allows for multiple lines of text
              expands: true, // Makes the TextField fill the container
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
