class DonationRecord {
  final String itemName;
  final int quantity;
  final String username;
  final DateTime date;

  DonationRecord({
    required this.itemName,
    required this.quantity,
    required this.username,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'itemName': itemName,
    'quantity': quantity,
    'username': username,
    'date': date.toIso8601String(),
  };

  Map<String, dynamic> toBackendJson() => {
    'item_name': itemName,
    'quantity': quantity,
    'username': username,
    'date': date.toIso8601String(),
  };

  static DonationRecord fromJson(Map<String, dynamic> json) => DonationRecord(
    itemName: json['itemName'],
    quantity: json['quantity'],
    username: json['username'],
    date: DateTime.parse(json['date']),
  );
}
