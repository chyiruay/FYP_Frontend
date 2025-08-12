import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const EditProfilePage({Key? key, this.initialData}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _houseNumberController;
  late TextEditingController _streetNameController;
  late TextEditingController _residentialAreaController;
  late TextEditingController _postcodeController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _phoneNumberController;
  String? _gender;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData ?? {};
    _usernameController = TextEditingController(text: d['username'] ?? '');
    _emailController = TextEditingController(text: d['email'] ?? '');
    _houseNumberController = TextEditingController(text: d['houseNumber'] ?? '');
    _streetNameController = TextEditingController(text: d['streetName'] ?? '');
    _residentialAreaController = TextEditingController(text: d['residentialArea'] ?? '');
    _postcodeController = TextEditingController(text: d['postcode'] ?? '');
    _cityController = TextEditingController(text: d['city'] ?? '');
    _stateController = TextEditingController(text: d['state'] ?? '');
    _phoneNumberController = TextEditingController(text: d['phoneNumber'] ?? '');
    _gender = d['gender'];
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _houseNumberController.dispose();
    _streetNameController.dispose();
    _residentialAreaController.dispose();
    _postcodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final profileData = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'phone_number': _phoneNumberController.text,
        'gender': _gender,
        'house_number': _houseNumberController.text,
        'street_name': _streetNameController.text,
        'residential_area': _residentialAreaController.text,
        'postcode': _postcodeController.text,
        'city': _cityController.text,
        'state': _stateController.text,
      };

      final success = await ApiService.updateUserProfile(profileData);
      
      setState(() {
        _isLoading = false;
      });

      if (success) {
        final prefs = await SharedPreferences.getInstance();

        final newFullAddress = '${_houseNumberController.text}, '
            '${_streetNameController.text}, '
            '${_residentialAreaController.text}, '
            '${_postcodeController.text}, '
            '${_cityController.text}, '
            '${_stateController.text}';

        await prefs.setString('username', _usernameController.text);
        await prefs.setString('email', _emailController.text);
        await prefs.setString('phone_number', _phoneNumberController.text);
        await prefs.setString('gender', _gender ?? '');
        await prefs.setString('house_number', _houseNumberController.text);
        await prefs.setString('street_name', _streetNameController.text);
        await prefs.setString('residential_area', _residentialAreaController.text);
        await prefs.setString('postcode', _postcodeController.text);
        await prefs.setString('city', _cityController.text);
        await prefs.setString('state', _stateController.text);
        await prefs.setString('full_address', newFullAddress);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to update profile.'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            'Edit Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Update your personal information',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBDEFB),
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor, // Solid blue color
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20), // Add top spacing
            _buildHeader(),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          _buildFormField(
                            controller: _usernameController,
                            label: 'Username',
                            icon: Icons.person,
                            validator: (v) => v == null || v.isEmpty ? 'Enter username' : null,
                          ),
                          
                          _buildFormField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                          ),
                          
                          _buildFormField(
                            controller: _phoneNumberController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.isEmpty ? 'Enter phone number' : null,
                          ),
                          
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField<String>(
                              value: _gender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: Icon(Icons.person_outline, color: Color(0xFF2196F3)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  borderSide: BorderSide(color: Color(0xFF2196F3), width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'M', child: Text('Male')),
                                DropdownMenuItem(value: 'F', child: Text('Female')),
                              ],
                              onChanged: (val) => setState(() => _gender = val),
                              validator: (v) => v == null || v.isEmpty ? 'Select gender' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Address Information Section
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Address Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          _buildFormField(
                            controller: _houseNumberController,
                            label: 'House Number',
                            icon: Icons.home,
                          ),
                          
                          _buildFormField(
                            controller: _streetNameController,
                            label: 'Street Name',
                            icon: Icons.streetview,
                          ),
                          
                          _buildFormField(
                            controller: _residentialAreaController,
                            label: 'Residential Area',
                            icon: Icons.location_city,
                          ),
                          
                          _buildFormField(
                            controller: _postcodeController,
                            label: 'Postcode',
                            icon: Icons.markunread_mailbox,
                          ),
                          
                          _buildFormField(
                            controller: _cityController,
                            label: 'City',
                            icon: Icons.location_city,
                          ),
                          
                          _buildFormField(
                            controller: _stateController,
                            label: 'State',
                            icon: Icons.map,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Save Button
                    _isLoading
                        ? Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _saveProfile,
                              icon: const Icon(Icons.save, size: 20),
                              label: const Text(
                                'Save Profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
