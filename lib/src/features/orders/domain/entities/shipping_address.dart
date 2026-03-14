class ShippingAddress {
  const ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
  });

  final String fullName;
  final String phone;
  final String address;
  final String city;

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'city': city,
      };

  factory ShippingAddress.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const ShippingAddress(fullName: '', phone: '', address: '', city: '');
    return ShippingAddress(
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
    );
  }

  String get displayText => '$fullName, $phone\n$address, $city';
}
