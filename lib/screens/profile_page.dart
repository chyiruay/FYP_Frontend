import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'donate_history.dart';
import 'edit_profile.dart';
import 'change_password.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';
  String gender = '';
  String phoneNumber = '';
  String houseNumber = '';
  String streetName = '';
  String residentialArea = '';
  String postcode = '';
  String city = '';
  String state ='';
  String fullAddress = '';
  bool isEmployee = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Unknown';
      email = prefs.getString('email') ?? 'Undisclosed';
      gender = prefs.getString('gender') ?? 'Undisclosed';
      phoneNumber = prefs.getString('phone_number') ?? 'Undisclosed';
      houseNumber = prefs.getString('house_number') ?? 'Undisclosed';
      streetName = prefs.getString('street_name') ?? 'Undisclosed';
      residentialArea = prefs.getString('residential_area') ?? 'Undisclosed';
      postcode = prefs.getString('postcode') ?? 'Undisclosed';
      city = prefs.getString('city') ?? 'Undisclosed';
      state = prefs.getString('state') ?? 'Undisclosed';
      fullAddress = prefs.getString('full_address') ?? 'Undisclosed';
      isEmployee = prefs.getBool('is_employee') ?? false;
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      email = prefs.getString('email') ?? '';
      phoneNumber = prefs.getString('phone_number') ?? '';
      gender = prefs.getString('gender') ?? '';
      houseNumber = prefs.getString('house_number') ?? 'Undisclosed';
      streetName = prefs.getString('street_name') ?? 'Undisclosed';
      residentialArea = prefs.getString('residential_area') ?? 'Undisclosed';
      postcode = prefs.getString('postcode') ?? 'Undisclosed';
      city = prefs.getString('city') ?? 'Undisclosed';
      state = prefs.getString('state') ?? 'Undisclosed';
      fullAddress = prefs.getString('full_address') ?? 'Undisclosed';
      isEmployee = prefs.getBool('is_employee') ?? false;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirm Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'User Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your account information',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          foregroundColor: textColor ?? Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBDEFB),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor, // Solid blue color
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20), // Add top spacing
            _buildProfileHeader(),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoCard('Username', username, Icons.person),
                  _buildInfoCard('Email', email, Icons.email),
                  _buildInfoCard('Gender', gender, Icons.person_outline),
                  _buildInfoCard('Phone Number', phoneNumber, Icons.phone),
                  _buildInfoCard('Address', fullAddress, Icons.location_on),
                  
                  const SizedBox(height: 24),
                  
                  // Actions Section
                  const Text(
                    'Account Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildActionButton(
                    title: 'View Donation History',
                    icon: Icons.history,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DonateHistoryPage()),
                      );
                    },
                    backgroundColor: Colors.blue[50],
                    textColor: Colors.blue[700],
                  ),
                  
                  _buildActionButton(
                    title: 'Edit Profile',
                    icon: Icons.edit,
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(initialData: {
                            'username': prefs.getString('username') ?? '',
                            'email': prefs.getString('email') ?? '',
                            'phoneNumber': prefs.getString('phone_number') ?? '',
                            'gender': prefs.getString('gender') ?? '',
                            'houseNumber': prefs.getString('house_number') ?? '',
                            'streetName': prefs.getString('street_name') ?? '',
                            'residentialArea': prefs.getString('residential_area') ?? '',
                            'postcode': prefs.getString('postcode') ?? '',
                            'city': prefs.getString('city') ?? '',
                            'state': prefs.getString('state') ?? '',
                          }),
                        ),
                      );

                      if (result == true) {
                        await _loadUserData();
                        setState(() {});
                      }
                    },
                    backgroundColor: Colors.green[50],
                    textColor: Colors.green[700],
                  ),
                  
                  _buildActionButton(
                    title: 'Change Password',
                    icon: Icons.lock_outline,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                      );
                    },
                    backgroundColor: Colors.orange[50],
                    textColor: Colors.orange[700],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Logout Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
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
}
