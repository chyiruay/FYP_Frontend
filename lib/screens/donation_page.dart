import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../models/donation.dart';
import 'donation_detail.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  late Future<List<Donation>> futureDonations;
  List<Donation> allDonations = [];
  List<Donation> filteredDonations = [];

  bool isLoggedIn = false;
  String selectedCategory = 'All';
  String selectedState = 'All';
  String selectedCity = 'All';

  List<String> categoryOptions = ['All'];
  List<String> stateOptions = ['All'];
  List<String> cityOptions = ['All'];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    setState(() {
      isLoggedIn = token != null;
    });
    if (isLoggedIn) {
      futureDonations = ApiService.fetchDonations();
      futureDonations.then((data) {
        allDonations = data;
        _initFilterOptions();
        _applyFilters();
      });
    }
  }

  void _initFilterOptions() {
    final categories = {'All', ...allDonations.map((d) => d.category.name)};
    final states = {'All', ...allDonations.map((d) => d.location.state)};
    final cities = {'All', ...allDonations.map((d) => d.location.city)};

    setState(() {
      categoryOptions = categories.toList();
      stateOptions = states.toList();
      cityOptions = cities.toList();
    });
  }

  void _applyFilters() {
    setState(() {
      filteredDonations = allDonations.where((d) {
        final matchCategory = selectedCategory == 'All' || d.category.name == selectedCategory;
        final matchState = selectedState == 'All' || d.location.state == selectedState;
        final matchCity = selectedCity == 'All' || d.location.city == selectedCity;
        return matchCategory && matchState && matchCity;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
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
            title: const Text('Donations'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: Center(
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 48, color: Colors.blueAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'Please log in to view donation information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

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
          title: const Text('Donations List'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt),
              tooltip: 'Filter',
              onPressed: _showFilterDialog,
            ),
          ],
        ),
        body: FutureBuilder<List<Donation>>(
          future: futureDonations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (filteredDonations.isEmpty) {
              return const Center(
                child: Text('No donations found.', style: TextStyle(fontSize: 16)),
              );
            }

            return ListView.builder(
              itemCount: filteredDonations.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final donation = filteredDonations[index];
                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.volunteer_activism, color: Colors.deepOrangeAccent, size: 32),
                    title: Text(
                      donation.donationName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category: ${donation.category.name}'),
                          Text('State: ${donation.location.state}'),
                          Text('City: ${donation.location.city}'),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonationDetailPage(donation: donation),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showFilterDialog() {
    String tempCategory = selectedCategory;
    String tempState = selectedState;
    String tempCity = selectedCity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Filter Donations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: tempCategory,
                        decoration: const InputDecoration(labelText: 'Category', filled: true),
                        items: categoryOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (value) => setModalState(() => tempCategory = value!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: tempState,
                        decoration: const InputDecoration(labelText: 'State', filled: true),
                        items: stateOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (value) => setModalState(() => tempState = value!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: tempCity,
                        decoration: const InputDecoration(labelText: 'City', filled: true),
                        items: cityOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (value) => setModalState(() => tempCity = value!),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                setModalState(() {
                                  tempCategory = 'All';
                                  tempState = 'All';
                                  tempCity = 'All';
                                });
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedCategory = tempCategory;
                                  selectedState = tempState;
                                  selectedCity = tempCity;
                                  _applyFilters();
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
