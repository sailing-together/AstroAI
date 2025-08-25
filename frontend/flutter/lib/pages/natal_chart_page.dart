import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:AstroAI/models/natal_chart_data.dart';
import 'package:AstroAI/widgets/natal_chart_painter.dart';
import 'dart:html' as html;

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
  print('[_fetchNatalChart] Function called.');
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
        print('Backend response data: $data');
        _saveHistory();
        setState(() {
          _natalChartData = NatalChartData.fromJson(data);
          print('Parsed NatalChartData: $_natalChartData');
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load natal chart: ${response.statusCode} - ${response.body}';
          print('Error response from backend: ${response.statusCode} - ${response.body}');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error connecting to backend: $e';
        print('Exception during API call: $e');
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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('Natal Chart', style: GoogleFonts.cinzel(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              title: const Text('Birth Date', style: TextStyle(color: Colors.white)),
              subtitle: Text('${_selectedDate.toLocal()}'.split(' ')[0], style: TextStyle(color: Colors.white70)),
              trailing: const Icon(Icons.calendar_today, color: Color(0xFFFBF7BA)),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: const Text('Birth Time', style: TextStyle(color: Colors.white)),
              subtitle: Text(_selectedTime.format(context), style: TextStyle(color: Colors.white70)),
              trailing: const Icon(Icons.access_time, color: Color(0xFFFBF7BA)),
              onTap: () => _selectTime(context),
            ),
            TextField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Birth Location (City, Country)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFBF7BA)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchNatalChart,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
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
              Column(
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: NatalChartPainter(_natalChartData!),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _PlanetPositions(planets: _natalChartData!.planets),
                  const SizedBox(height: 32),
                  _HousePositions(houses: _natalChartData!.houses),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PlanetPositions extends StatelessWidget {
  final List<Planet> planets;

  const _PlanetPositions({required this.planets});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Planet Positions',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: Colors.white.withOpacity(0.2)),
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                ),
                children: [
                  _buildHeaderCell('Planet'),
                  _buildHeaderCell('Zodiac'),
                  _buildHeaderCell('House'),
                ],
              ),
              ...planets.map((planet) => TableRow(
                children: [
                  _buildTableCell('${planet.symbol} ${planet.name}'),
                  _buildTableCell('${planet.degree.toStringAsFixed(2)}° ${planet.zodiacSign}'),
                  _buildTableCell(planet.houseNumber.toString()),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.raleway(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.raleway(color: Colors.white70),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _HousePositions extends StatelessWidget {
  final List<House> houses;

  const _HousePositions({required this.houses});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'House Cusps',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: Colors.white.withOpacity(0.2)),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                ),
                children: [
                  _buildHeaderCell('House'),
                  _buildHeaderCell('Zodiac Position'),
                ],
              ),
              ...houses.map((house) => TableRow(
                children: [
                  _buildTableCell(house.houseNumber.toString()),
                  _buildTableCell('${house.startDegree.toStringAsFixed(2)}°'),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.raleway(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.raleway(color: Colors.white70),
        textAlign: TextAlign.center,
      ),
    );
  }
}