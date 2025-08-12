class User {
  final int id;
  final String username;
  final String email;
  final bool isEmployee;
  final String houseNumber;
  final String streetName;
  final String residentialArea;
  final String postcode;
  final String city;
  final String state;
  final String fullAddress;
  final String phoneNumber;
  final String gender;
  final DateTime dateJoined;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isEmployee,
    required this.houseNumber,
    required this.streetName,
    required this.residentialArea,
    required this.postcode,
    required this.city,
    required this.state,
    required this.fullAddress,
    required this.phoneNumber,
    required this.gender,
    required this.dateJoined,
    required this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      isEmployee: json['is_employee'],
      houseNumber: json['house_number'] ?? '',
      streetName: json['street_name'] ?? '',
      residentialArea: json['residential_area'] ?? '',
      postcode: json['postcode'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      fullAddress: json['full_address'],
      phoneNumber: json['phone_number'] ?? '',
      gender: json['gender'] ?? '',
      dateJoined: DateTime.parse(json['date_joined']),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
    );
  }
}
