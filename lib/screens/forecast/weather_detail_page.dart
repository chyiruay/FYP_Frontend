import 'package:flutter/material.dart';

class WeatherDetailPage extends StatelessWidget {
  final String locationName;
  final List allForecasts;

  const WeatherDetailPage({
    super.key,
    required this.locationName,
    required this.allForecasts,
  });

  @override
  Widget build(BuildContext context) {
    final locationForecasts = {
      for (var f in allForecasts)
        if (f['location']['location_name'] == locationName)
          f['date']: f
    }.values.toList()
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1900);
        final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1900);
        return dateA.compareTo(dateB);
      });


    final today = DateTime.now();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFFBBDEFB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Weather Forecast: $locationName'),
          centerTitle: true,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: locationForecasts.length,
          itemBuilder: (context, index) {
            final forecast = locationForecasts[index];

            final dateStr = forecast['date'] ?? '';
            final date = DateTime.tryParse(dateStr) ?? DateTime(1900);
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;

            final morning = forecast['morning_forecast'] ?? '';
            final afternoon = forecast['afternoon_forecast'] ?? '';
            final night = forecast['night_forecast'] ?? '';
            final minTemp = forecast['min_temp']?.toString() ?? 'N/A';
            final maxTemp = forecast['max_temp']?.toString() ?? 'N/A';

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              color: isToday ? Colors.lightBlue[50] : Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        isToday ? '$dateStr (Today)' : dateStr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Morning: $morning')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.wb_sunny, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Afternoon: $afternoon')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.nightlight_round, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Night: $night')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.thermostat, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Temperature: $minTemp°C ~ $maxTemp°C',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
