// lib/widgets/base_layout.dart
import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onTabTapped;
  final bool isLoggedIn;
  final bool showBottomNav;
  final PreferredSizeWidget? customAppBar;
  final VoidCallback? onLoginStatusChanged;

  const BaseLayout({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTabTapped,
    required this.isLoggedIn,
    this.showBottomNav = true,
    this.customAppBar,
    this.onLoginStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar ??
          AppBar(
            title: const Text('Flood Alert'),
            actions: [
              isLoggedIn
                  ? IconButton(
                icon: const Icon(Icons.account_circle),
                tooltip: 'Profile',
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
              )
                  : IconButton(
                icon: const Icon(Icons.person_add),
                tooltip: 'Register',
                  onPressed: () {
                    Navigator.pushNamed(context, '/register').then((result) {
                      if (result == true && onLoginStatusChanged != null) {
                        onLoginStatusChanged!(); // 调用传入的函数
                      }
                    });
                  }
              ),
            ],
          ),
      body: body,
      bottomNavigationBar: showBottomNav
          ? Container(
        decoration: const BoxDecoration(
          color: Colors.white, // 可改为主题色
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 8),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTabTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Forecast'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Donation'),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
            ],
          ),
        ),
      )
          : null,
    );
  }
}
