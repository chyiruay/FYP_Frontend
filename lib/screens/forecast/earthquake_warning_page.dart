import 'package:flutter/material.dart';
import '../../api/weather.dart';

class EarthquakeWarningPage extends StatefulWidget {
  const EarthquakeWarningPage({super.key});

  @override
  _EarthquakeWarningPageState createState() => _EarthquakeWarningPageState();
}

class _EarthquakeWarningPageState extends State<EarthquakeWarningPage> {
  final WeatherService _weatherService = WeatherService();
  late Future<dynamic> _futureEarthquake;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureEarthquake = _weatherService.fetchEarthquakeWarnings(queryParameters: {'limit': ''});
    });
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading earthquake data...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.terrain,
              size: 48,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Earthquakes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No earthquake warnings currently available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarthquakeCard(Map<String, dynamic> quakeItem) {
    final utcDateTime = quakeItem['utcdatetime'] ?? '';
    final localDateTime = quakeItem['localdatetime'] ?? '';
    final location = quakeItem['location'] ?? 'Unknown';
    final mag = quakeItem['magdefault']?.toString() ?? 'N/A';
    final depth = quakeItem['depth']?.toString() ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earthquake: $location',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.access_time, 'UTC Time: $utcDateTime'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.access_time, 'Local Time: $localDateTime'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.linear_scale, 'Magnitude: $mag'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.terrain, 'Depth: $depth km'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.blue[700],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBDEFB),
      appBar: AppBar(
        title: const Text(
          'Earthquake Warnings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        child: FutureBuilder(
          future: _futureEarthquake,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Error Loading Data',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              List earthquakes = snapshot.data is List
                  ? snapshot.data as List
                  : snapshot.data['earthquakes'];

              if (earthquakes == null || earthquakes.isEmpty) {
                return _buildEmptyState();
              }

              // Sort earthquakes by datetime (newest first)
              earthquakes.sort((a, b) {
                final dateA = a['utcdatetime'] ?? '';
                final dateB = b['utcdatetime'] ?? '';
                return dateB.compareTo(dateA); // Descending order
              });

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: earthquakes.length,
                itemBuilder: (context, index) {
                  final quakeItem = earthquakes[index];
                  return _buildEarthquakeCard(quakeItem);
                },
              );
            } else {
              return _buildEmptyState();
            }
          },
        ),
      ),
    );
  }
}