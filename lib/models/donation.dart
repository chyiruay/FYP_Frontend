import 'category.dart';
import 'location.dart';

class Donation {
  final int id;
  final String donationName;
  final int donationQuantity;
  final Category category;
  final Location location;

  Donation({
    required this.id,
    required this.donationName,
    required this.donationQuantity,
    required this.category,
    required this.location,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      donationName: json['donationName'],
      donationQuantity: json['donationQuantity'],
      category: Category.fromJson(json['category']),
      location: Location.fromJson(json['location']),
    );
  }
}
