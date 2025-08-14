import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

const double topHeight = 80;
const double bottomHeight = 40;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pipeline Tool',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
        cardTheme: const CardTheme(color: Color(0xFF1E1E1E)),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  bool inCloud = false;
  String fromValue = 'Option 1';
  String toValue = 'Option 1';

  Uint8List? _imageBytes; // dynamically loaded image bytes
  String _status = 'Idle';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top bar
          Container(
            height: topHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF1A1A1A),
            child: Row(
              children: [
                const Text('Pipeline Tool',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => setState(() => _status = 'Running...'),
                  child: const Text('Run'),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Checkbox(
                      value: inCloud,
                      onChanged: (val) {
                        setState(() {
                          inCloud = val ?? false;
                          _status = inCloud ? 'Cloud mode enabled' : 'Cloud mode disabled';
                        });
                      },
                    ),
                    const Text('in Cloud'),
                  ],
                ),
                const SizedBox(width: 12),
                _buildDropdown(
                  label: 'From',
                  value: fromValue,
                  enabled: !inCloud,
                  onChanged: (v) => setState(() => fromValue = v!),
                ),
                const SizedBox(width: 12),
                _buildDropdown(
                  label: 'To',
                  value: toValue,
                  enabled: !inCloud,
                  onChanged: (v) => setState(() => toValue = v!),
                ),
              ],
            ),
          ),

          // Middle split
          Expanded(
            child: Row(
              children: [
                // Left 75%
                Expanded(
                  flex: 3,
                  child: _buildMainTabs(),
                ),
                // Right 25%
                Expanded(
                  flex: 1,
                  child: Container(
                    color: const Color(0xFF1E1E1E),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Load Image from Disk'),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.black,
                            ),
                            child: Center(
                              child: _imageBytes != null
                                  ? Image.memory(_imageBytes!, fit: BoxFit.contain)
                                  : Image.asset('assets/sample.png', fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom status
          Container(
            height: bottomHeight,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            color: const Color(0xFF1A1A1A),
            child: Text('Status: $_status'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required bool enabled,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Text('$label: '),
        const SizedBox(width: 6),
        DropdownButton<String>(
          dropdownColor: const Color(0xFF2A2A2A),
          value: value,
          onChanged: enabled ? onChanged : null,
          items: const ['Option 1', 'Option 2', 'Option 3']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMainTabs() {
    const mainTabs = ['Parse', 'Build', 'Push', 'Simulate'];
    return DefaultTabController(
      length: mainTabs.length,
      child: Column(
        children: [
          const Material(
            color: Color(0xFF1E1E1E),
            child: TabBar(
              indicatorColor: Colors.lightBlueAccent,
              tabs: [
                Tab(text: 'Parse'),
                Tab(text: 'Build'),
                Tab(text: 'Push'),
                Tab(text: 'Simulate'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: mainTabs.map((_) => _buildStepTabs()).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTabs() {
    const steps = ['Step 1', 'Step 2', 'Step 3'];
    return DefaultTabController(
      length: steps.length,
      child: Column(
        children: [
          const Material(
            color: Color(0xFF252525),
            child: TabBar(
              indicatorColor: Colors.amber,
              tabs: [
                Tab(text: 'Step 1'),
                Tab(text: 'Step 2'),
                Tab(text: 'Step 3'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: steps.map((_) => _buildConsole()).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsole() {
    const dummy = '''
$ flutter run
[INFO] Starting app...
[INFO] Loading modules...
[INFO] Doing important work...
[WARN] Something might be slow...
[OK] Completed successfully.
''';
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(12),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: SelectableText(
            dummy,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (res != null && res.files.isNotEmpty) {
        setState(() {
          _imageBytes = res.files.first.bytes;
          _status = 'Loaded image: ${res.files.first.name}';
        });
      }
    } catch (e) {
      setState(() => _status = 'Failed to load image: $e');
    }
  }
}
