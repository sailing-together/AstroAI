import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:AstroAI/models/natal_chart_data.dart';
import 'package:AstroAI/widgets/natal_chart_painter.dart';
import 'package:AstroAI/widgets/common/navigation_header.dart';
import 'dart:html' as html;
import '../theme/app_theme.dart';

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
      backgroundColor: Theme.of(context).palette.lightPink,
      body: Stack(
        children: [
          // Main content with top padding to account for fixed header
          Padding(
            padding: const EdgeInsets.only(top: 89), // Header height
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 89,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFF3F8),
                      Color(0xFFF0F8FF),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Page Header
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                offset: const Offset(0, 8),
                                blurRadius: 32,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'NATAL CHART',
                                style: GoogleFonts.cinzel(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  letterSpacing: 2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Discover your complete astrological blueprint',
                                style: GoogleFonts.raleway(
                                  fontSize: 18,
                                  color: Colors.black.withValues(alpha: 0.8),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Input Form Container
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                offset: const Offset(0, 4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (_history.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Map<String, dynamic>>(
                                      value: null, // Always show hint text
                                      isExpanded: true,
                                      hint: Text("Select from History", style: TextStyle(color: Colors.grey.shade600)),
                                      icon: Icon(Icons.history, color: Theme.of(context).palette.accent),
                                      dropdownColor: Colors.white,
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
                                            style: const TextStyle(color: Colors.black87),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              if (_history.isNotEmpty) const SizedBox(height: 20),

                              // Birth Information Row
                              Row(
                                children: [
                                  // Birth Date
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: InkWell(
                                        onTap: () => _selectDate(context),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today, color: Theme.of(context).palette.accent, size: 20),
                                                const SizedBox(width: 8),
                                                Text('Birth Date', style: GoogleFonts.raleway(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text('${_selectedDate.toLocal()}'.split(' ')[0], style: GoogleFonts.raleway(color: Colors.grey.shade600, fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Birth Time
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: InkWell(
                                        onTap: () => _selectTime(context),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.access_time, color: Theme.of(context).palette.accent, size: 20),
                                                const SizedBox(width: 8),
                                                Text('Birth Time', style: GoogleFonts.raleway(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(_selectedTime.format(context), style: GoogleFonts.raleway(color: Colors.grey.shade600, fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Birth Location
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _locationController,
                                      style: GoogleFonts.raleway(color: Colors.black87),
                                      decoration: InputDecoration(
                                        labelText: 'Birth Location (City, Country)',
                                        labelStyle: GoogleFonts.raleway(color: Colors.grey.shade600),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Theme.of(context).palette.accent),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Generate Button
                              ElevatedButton(
                                onPressed: _isLoading ? null : _fetchNatalChart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).palette.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 8,
                                ),
                                child: _isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                                    : Text('Generate Natal Chart', style: GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        
                        // Error Message
                        if (_errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.raleway(
                                color: Colors.red.shade300,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        
                        // Results Section
                        if (_natalChartData != null)
                          Column(
                            children: [
                              const SizedBox(height: 32),
                              
                              // Chart Display
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'YOUR NATAL CHART',
                                      style: GoogleFonts.cinzel(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Center(
                                      child: CustomPaint(
                                        size: const Size(300, 300),
                                        painter: NatalChartPainter(_natalChartData!),
                                      ),
                                    ),
                                  ],
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
                ),
              ),
            ),
          ),
          // Fixed header on top
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NavigationHeader(),
          ),
        ],
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