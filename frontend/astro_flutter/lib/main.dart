import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                              const SizedBox(width: 40),
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
                            onPressed: isValid ? _scrollToNextSection : null,
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
              child: const Center(
                child: Text(
                  "这里将显示你的星座和性格分析",
                  style: TextStyle(fontSize: 24, color: Colors.white),
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

// Natal Chart page placeholder
class NatalChartPage extends StatelessWidget {
  const NatalChartPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Natal Chart Page', style: TextStyle(fontSize: 32, color: Color(0xFF5A5683))),
    );
  }
}
