import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/donation.dart';
import 'donation_form.dart';

class DonationDetailPage extends StatelessWidget {
  final Donation donation;

  const DonationDetailPage({super.key, required this.donation});

  Future<void> _checkLoginAndNavigate(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('You must be logged in to make a donation.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DonationFormPage(donation: donation),
        ),
      );
    }
  }

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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(donation.donationName),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Profile',
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Donation Details',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  _buildDetailRow(Icons.volunteer_activism, 'Donation Name', donation.donationName),
                  _buildDetailRow(Icons.numbers, 'Quantity Needed', donation.donationQuantity.toString()),
                  _buildDetailRow(Icons.category, 'Category', donation.category.name),
                  _buildDetailRow(Icons.home, 'House No.', donation.location.houseNumber),
                  _buildDetailRow(Icons.route, 'Street', donation.location.streetName),
                  _buildDetailRow(Icons.location_city, 'Area', donation.location.residentialArea),
                  _buildDetailRow(Icons.markunread_mailbox, 'Postcode', donation.location.postcode),
                  _buildDetailRow(Icons.location_on, 'City', donation.location.city),
                  _buildDetailRow(Icons.map, 'State', donation.location.state),

                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _checkLoginAndNavigate(context),
                      icon: const Icon(Icons.volunteer_activism),
                      label: const Text('Donate'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$title: $value',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
