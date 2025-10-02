class User {
  final String uid;
  final String displayName;
  final String email;
  final String? photoURL;
  final String? mobileNumber;
  final bool hasCompletedFirstOrder;

  User({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL,
    this.mobileNumber,
    this.hasCompletedFirstOrder = false,
  });

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      uid: id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'] as String?,
      mobileNumber: data['mobileNumber'] as String?,
      hasCompletedFirstOrder: data['hasCompletedFirstOrder'] ?? false,
    );
  }
}
