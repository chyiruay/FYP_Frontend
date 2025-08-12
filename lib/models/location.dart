class Location {
  final int id;
  final String houseNumber;
  final String streetName;
  final String residentialArea;
  final String postcode;
  final String city;
  final String state;

  Location({
    required this.id,
    required this.houseNumber,
    required this.streetName,
    required this.residentialArea,
    required this.postcode,
    required this.city,
    required this.state,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      houseNumber: json['house_number'],
      streetName: json['street_name'],
      residentialArea: json['residential_area'],
      postcode: json['postcode'],
      city: json['city'],
      state: json['state'],
    );
  }
}
