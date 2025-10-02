class Address {
  final String id;
  final String fullName;
  final String phone;
  final String? alternatePhone;
  final String street;
  final String city;
  final String pinCode;
  final String? village;
  final double lat;
  final double lng;
  final String type;
  final bool isDefault;

  Address({
    required this.id,
    required this.fullName,
    required this.phone,
    this.alternatePhone,
    required this.street,
    required this.city,
    required this.pinCode,
    this.village,
    required this.lat,
    required this.lng,
    required this.type,
    this.isDefault = false,
  });

  factory Address.fromFirestore(Map<String, dynamic> data, String id) {
    return Address(
      id: id,
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      alternatePhone: data['alternatePhone'] as String?,
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      pinCode: data['pinCode'] ?? '',
      village: data['village'] as String?,
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      type: data['type'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'phone': phone,
      'alternatePhone': alternatePhone,
      'street': street,
      'city': city,
      'pinCode': pinCode,
      'village': village,
      'lat': lat,
      'lng': lng,
      'type': type,
      'isDefault': isDefault,
    };
  }
}
