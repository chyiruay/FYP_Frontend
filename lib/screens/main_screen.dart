import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forecast_page.dart';
import 'donation_page.dart';
import 'map_page.dart';
import '../widgets/base_layout.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;

  final List<Widget> _pages = const [
    ForecastPage(),
    DonationPage(),
    MapPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      currentIndex: _currentIndex,
      onTabTapped: _onItemTapped,
      isLoggedIn: _isLoggedIn,
      onLoginStatusChanged: _loadLoginStatus,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: _pages[_currentIndex],
      ),
    );
  }
}
