import 'package:flutter/material.dart';
import 'package:water_alert_app/screens/forecast/water_level_page.dart';
import 'forecast/weather_forecast_page.dart';
import 'forecast/warning_page.dart';
import 'forecast/earthquake_warning_page.dart';
import 'forecast/water_level_page.dart';

class ForecastPage extends StatelessWidget {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFFBBDEFB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.analytics,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Forecast & Alerts',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Stay informed with real-time weather and safety updates',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Services Grid
              const Text(
                'Available Services',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),
              
              _buildCard(
                context,
                icon: Icons.cloud,
                title: 'Weather Forecast',
                subtitle: 'Get detailed weather information',
                page: const WeatherForecastPage(),
                color: Colors.lightBlueAccent,
                gradient: [Colors.lightBlueAccent, Colors.lightBlueAccent.shade700],
              ),
              
              const SizedBox(height: 16),
              
              _buildCard(
                context,
                icon: Icons.water,
                title: 'Water Level',
                subtitle: 'Monitor water levels and flood alerts',
                page: const WaterLevelPage(),
                color: Colors.blueAccent,
                gradient: [Colors.blueAccent, Colors.blueAccent.shade700],
              ),
              
              const SizedBox(height: 16),
              
              _buildCard(
                context,
                icon: Icons.warning,
                title: 'Alert Information',
                subtitle: 'Emergency alerts and notifications',
                page: const WarningPage(),
                color: Colors.amber,
                gradient: [Colors.amber, Colors.amber.shade700],
              ),
              
              const SizedBox(height: 16),
              
              _buildCard(
                context,
                icon: Icons.public,
                title: 'Earthquake Warning',
                subtitle: 'Seismic activity and safety alerts',
                page: const EarthquakeWarningPage(),
                color: Colors.redAccent,
                gradient: [Colors.redAccent, Colors.redAccent.shade700],
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
    required Color color,
    required List<Color> gradient,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon, 
                  size: 32, 
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios, 
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
