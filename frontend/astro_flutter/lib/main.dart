import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:AstroAI/models/natal_chart_data.dart'; // Import the new data model
import 'package:AstroAI/widgets/natal_chart_painter.dart'; // Import the painter

void main() {
  runApp(const AstroAiApp());
}

class AstroAiApp extends StatelessWidget {
  const AstroAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroAi',
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
        title: const Text('AstroAI', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5A5683),
        actions: [
          TextButton(
            onPressed: () => _onMenuTap(0),
            child: Text('Home', style: TextStyle(color: _selectedIndex == 0 ? Color(0xFFFBF7BA) : Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => _onMenuTap(1),
            child: Text('Horoscope', style: TextStyle(color: _selectedIndex == 1 ? Color(0xFFFBF7BA) : Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => _onMenuTap(2),
            child: Text('Compatibility', style: TextStyle(color: _selectedIndex == 2 ? Color(0xFFFBF7BA) : Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => _onMenuTap(3),
            child: Text('Natal Chart', style: TextStyle(color: _selectedIndex == 3 ? Color(0xFFFBF7BA) : Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
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
  final List<int> years = List.generate(126, (i) => 1900 + i);

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
    return Center(
      child: Text('Horoscope Page', style: TextStyle(fontSize: 32, color: Color(0xFF5A5683))),
    );
  }
}

// Compatibility page placeholder
class CompatibilityPage extends StatelessWidget {
  const CompatibilityPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
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
          ListTile(
            title: const Text('Birth Date'),
            subtitle: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
          ),
          ListTile(
            title: const Text('Birth Time'),
            subtitle: Text(_selectedTime.format(context)),
            trailing: const Icon(Icons.access_time),
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
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Generate Natal Chart'),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_natalChartData != null)
            Expanded(
              child: Center(
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.width * 0.8), // Make it square and responsive
                  painter: NatalChartPainter(_natalChartData!),
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
