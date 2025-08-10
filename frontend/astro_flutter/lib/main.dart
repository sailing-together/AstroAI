import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:AstroAI/models/natal_chart_data.dart'; // Import the new data model
import 'package:AstroAI/widgets/natal_chart_painter.dart'; // Import the painter
import 'dart:html' as html;

void main() {
  runApp(const AstroAiApp());
}

class AstroAiApp extends StatelessWidget {
  const AstroAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroAi',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF5A5683),
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5A5683),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFBF7BA),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainMenuPage(),
    );
  }
}

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BirthdayInputPage(),
    const HoroscopePage(),
    const CompatibilityPage(),
    const NatalChartPage(),
  ];

  void _onMenuTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AstroAI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          _buildMenuButton(context, 'Home', 0),
          _buildMenuButton(context, 'Horoscope', 1),
          _buildMenuButton(context, 'Compatibility', 2),
          _buildMenuButton(context, 'Natal Chart', 3),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, int index) {
    final bool isSelected = _selectedIndex == index;
    return TextButton(
      onPressed: () => _onMenuTap(index),
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Colors.black.withOpacity(0.2) : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFFFBF7BA) : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Home page (already implemented as BirthdayInputPage)
class BirthdayInputPage extends StatefulWidget {
  const BirthdayInputPage({super.key});

  @override
  State<BirthdayInputPage> createState() => _BirthdayInputPageState();
}

class _BirthdayInputPageState extends State<BirthdayInputPage> {
  final ScrollController _scrollController = ScrollController();

  int? selectedDay;
  int? selectedMonth;
  int? selectedYear = 2000;

  final List<int> days = List.generate(31, (i) => i + 1);
  final List<int> months = List.generate(12, (i) => i + 1);
  final List<int> years = List.generate(126, (i) => 1900 + i).reversed.toList();

  bool get isValid => selectedDay != null && selectedMonth != null && selectedYear != null;
 
  
  Map<String, String> result = {};
  bool loading = false;
  
  Future<void> fetchHoroscope() async {
    setState(() {
      loading = true;
      result = {};
    });
    final url = Uri.parse('http://localhost:8000/horoscope');
    final body = jsonEncode({
      "birthdate": "${selectedYear ?? 2000}-${(selectedMonth ?? 1).toString().padLeft(2, '0')}-${(selectedDay ?? 1).toString().padLeft(2, '0')}"
    });
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          result = {
            "NAME": data["overall_horoscope"] ?? "",
            "LOVE": data["love_advice"] ?? "",
            "CAREER": data["career_advice"] ?? "",
            "WEALTH": data["wealth_advice"] ?? "",
            "SUGGESTION": data["daily_suggestion"] ?? "",
            "ENCOURAGEMENT": data["daily_encouragement_message"] ?? "",
          };
        });
      } else {
        setState(() {
          result = {"NAME": "Error: ${res.statusCode}"};
        });
      }
    } catch (e) {
      setState(() {
        result = {"NAME": "Network error"};
      });
    }
    setState(() {
      loading = false;
    });
  }

  void _scrollToNextSection() {
    _scrollController.animateTo(
      MediaQuery.of(context).size.height,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // 页面 1：输入生日
            Stack(
              children: [
                // 背景图（放大 1.5 倍）
                SizedBox(
                  height: screenHeight,
                  width: double.infinity,
                  child: Transform.scale(
                    scale: 1.5,
                    child: Image.asset(
                      'assets/space.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // 内容
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5A5683).withOpacity(0.57),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 一行：标题 + 选择器
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 左侧标题
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: const [
                                  Text(
                                    "ENTER",
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontFamily: 'Kabel',
                                      color: Color(0xFFFBF7BA),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "YOUR",
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontFamily: 'Kabel',
                                      color: Color(0xFFFBF7BA),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "BIRTHDAY",
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontFamily: 'Kabel',
                                      color: Color(0xFFFBF7BA),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              // 右侧选择器
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildPicker("Day", days, selectedDay, (v) => setState(() => selectedDay = v)),
                                      const SizedBox(width: 16),
                                      _buildPicker("Month", months, selectedMonth, (v) => setState(() => selectedMonth = v)),
                                      const SizedBox(width: 16),
                                      _buildPicker("Year", years, selectedYear, (v) => setState(() => selectedYear = v)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // 圆形按钮
                          ElevatedButton(
                            onPressed: isValid && !loading ? () async {
                              await fetchHoroscope();
                              _scrollToNextSection();
                            } : null,
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor: isValid
                                  ? const Color(0xFFFBF7BA)
                                  : Colors.grey.shade600,
                              padding: const EdgeInsets.all(24),
                            ),
                            child: const Icon(Icons.arrow_downward, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 页面 2：结果页面
            Container(
              height: screenHeight,
              width: double.infinity,
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: ListView(
                  // 用 ListView 替换 Column，防止溢出
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _ResultSection(title: 'NAME', content: result["NAME"] ?? ''),
                    const SizedBox(height: 16),
                    _ResultSection(title: 'LOVE', content: result["LOVE"] ?? ''),
                    const SizedBox(height: 16),
                    _ResultSection(title: 'CAREER', content: result["CAREER"] ?? ''),
                    const SizedBox(height: 16),
                    _ResultSection(title: 'WEALTH', content: result["WEALTH"] ?? ''),
                    const SizedBox(height: 16),
                    _ResultSection(title: 'SUGGESTION', content: result["SUGGESTION"] ?? ''),
                    const SizedBox(height: 16),
                    _ResultSection(title: 'ENCOURAGEMENT', content: result["ENCOURAGEMENT"] ?? ''),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(String label, List<int> items, int? selectedValue, Function(int) onSelected) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFFBF7BA))),
        SizedBox(
          height: 80,
          width: 80,
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(
              initialItem: selectedValue != null ? items.indexOf(selectedValue) : (label == "Year" ? items.indexOf(2000) : 0),
            ),
            itemExtent: 32,
            onSelectedItemChanged: (index) => onSelected(items[index]),
            children: items
                .map((e) => Center(child: Text(e.toString(), style: const TextStyle(color: Colors.white))))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// Horoscope page placeholder
class HoroscopePage extends StatelessWidget {
  const HoroscopePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Horoscope Page', style: TextStyle(fontSize: 32, color: Color(0xFF5A5683))),
    );
  }
}

// Compatibility page placeholder
class CompatibilityPage extends StatelessWidget {
  const CompatibilityPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Compatibility Page', style: TextStyle(fontSize: 32, color: Color(0xFF5A5683))),
    );
  }
}

// Natal Chart page
class NatalChartPage extends StatefulWidget {
  const NatalChartPage({super.key});

  @override
  State<NatalChartPage> createState() => _NatalChartPageState();
}

class _NatalChartPageState extends State<NatalChartPage> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _locationController = TextEditingController();

  NatalChartData? _natalChartData;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // --- Session Storage Helpers ---
  
  void _loadHistory() {
    final historyJson = html.window.sessionStorage['astro_history'];
    if (historyJson != null) {
      final List<dynamic> decoded = json.decode(historyJson);
      final history = List<Map<String, dynamic>>.from(decoded);
      if (history.isNotEmpty) {
        _applyHistoryEntry(history.first, isInitialLoad: true);
      }
      // Update state once with all loaded data
      setState(() {
        _history = history;
      });
    }
  }

  void _saveHistory() {
    final newEntry = {
      'date': _selectedDate.toIso8601String().split('T')[0],
      'time': '${_selectedTime.hour}:${_selectedTime.minute}',
      'location': _locationController.text,
    };

    // Create a new list for state update to ensure widget rebuilds
    final newHistory = List<Map<String, dynamic>>.from(_history);

    // Avoid duplicates
    newHistory.removeWhere((entry) => 
      entry['date'] == newEntry['date'] &&
      entry['time'] == newEntry['time'] &&
      entry['location'] == newEntry['location']
    );

    newHistory.insert(0, newEntry);

    // Limit history to 5 entries
    if (newHistory.length > 5) {
      _history = newHistory.sublist(0, 5);
    } else {
      _history = newHistory;
    }

    html.window.sessionStorage['astro_history'] = json.encode(_history);
    // Update state with the new list
    setState(() {});
  }

  void _applyHistoryEntry(Map<String, dynamic> entry, {bool isInitialLoad = false}) {
    final newDate = DateTime.parse(entry['date']);
    final timeParts = (entry['time'] as String).split(':');
    final newTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    final newLocation = entry['location'] as String;

    // To avoid lag, only call setState for what's necessary
    if (isInitialLoad) {
      _selectedDate = newDate;
      _selectedTime = newTime;
      _locationController.text = newLocation;
    } else {
      setState(() {
        _selectedDate = newDate;
        _selectedTime = newTime;
        _locationController.text = newLocation;
      });
    }
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _fetchNatalChart() async {
    if (_locationController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a birth location.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _natalChartData = null;
    });

    final url = Uri.parse('http://localhost:8000/natal_chart');
    final body = jsonEncode({
      "birth_date": _selectedDate.toIso8601String().split('T')[0],
      "birth_time": '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      "birth_location": _locationController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _saveHistory();
        setState(() {
          _natalChartData = NatalChartData.fromJson(data);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load natal chart: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error connecting to backend: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // History Dropdown
          if (_history.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  value: null, // Always show hint text
                  isExpanded: true,
                  hint: const Text("Select from History", style: TextStyle(color: Colors.white70)),
                  icon: const Icon(Icons.history, color: Color(0xFFFBF7BA)),
                  dropdownColor: Colors.grey[850],
                  onChanged: (Map<String, dynamic>? newValue) {
                    if (newValue != null) {
                      _applyHistoryEntry(newValue);
                    }
                  },
                  items: _history.map<DropdownMenuItem<Map<String, dynamic>>>((entry) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: entry,
                      child: Text(
                        '${entry["location"]} - ${entry["date"]} @ ${entry["time"]}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 20),

          ListTile(
            title: const Text('Birth Date'),
            subtitle: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
            trailing: const Icon(Icons.calendar_today, color: Color(0xFFFBF7BA)),
            onTap: () => _selectDate(context),
          ),
          ListTile(
            title: const Text('Birth Time'),
            subtitle: Text(_selectedTime.format(context)),
            trailing: const Icon(Icons.access_time, color: Color(0xFFFBF7BA)),
            onTap: () => _selectTime(context),
          ),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Birth Location (City, Country)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _fetchNatalChart,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
                : const Text('Generate Natal Chart'),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          if (_natalChartData != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.width * 0.8),
                    painter: NatalChartPainter(_natalChartData!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final String title;
  final String content;
  const _ResultSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF23213A),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFBF7BA),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ]
        ],
      ),
    );
  }
}