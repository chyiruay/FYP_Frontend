import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/donation.dart';
import '../models/donation_record.dart';
import '../api/api_service.dart';
import 'thank_you_page.dart';

class DonationFormPage extends StatefulWidget {
  final Donation donation;

  const DonationFormPage({super.key, required this.donation});

  @override
  State<DonationFormPage> createState() => _DonationFormPageState();
}

class _DonationFormPageState extends State<DonationFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedItemName;
  int? quantity;
  String? username;

  @override
  void initState() {
    super.initState();
    selectedItemName = widget.donation.donationName;
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Unknown';
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newRecord = DonationRecord(
        itemName: selectedItemName!,
        quantity: quantity!,
        username: username!,
        date: DateTime.now(),
      );

      // Save to local history
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? existingData = prefs.getString('donation_history');
      List<Map<String, dynamic>> recordList = [];

      if (existingData != null) {
        recordList = List<Map<String, dynamic>>.from(json.decode(existingData));
      }

      recordList.add(newRecord.toJson());
      await prefs.setString('donation_history', json.encode(recordList));

      // Submit to the backend
      final success = await ApiService.submitDonationRecord(
        donationId: widget.donation.id!,
        quantity: quantity!,
      );

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ThankYouPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit donation. Please try again.")),
        );
      }
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
          title: const Text('Donate Item'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: username == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text(
                      'Donation Form',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Donation Name
                    TextFormField(
                      initialValue: widget.donation.donationName,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Donation Name',
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quantity
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Donation Quantity',
                        hintText:
                        'Max: ${widget.donation.donationQuantity}',
                        border: const OutlineInputBorder(),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        final input = int.tryParse(value);
                        if (input == null || input <= 0) {
                          return 'Please enter a valid quantity';
                        }
                        if (input > widget.donation.donationQuantity) {
                          return 'Only ${widget.donation.donationQuantity} needed';
                        }
                        return null;
                      },
                      onSaved: (value) => quantity = int.parse(value!),
                    ),
                    const SizedBox(height: 16),

                    // Username
                    TextFormField(
                      initialValue: username,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Donator',
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Submit Donation'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _submitForm,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
