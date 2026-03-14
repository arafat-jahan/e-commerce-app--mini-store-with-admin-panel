class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName = '',
    this.phone = '',
    this.defaultAddress = '',
    this.city = '',
  });

  final String uid;
  final String email;
  final String role;
  final String displayName;
  final String phone;
  final String defaultAddress;
  final String city;

  bool get isAdmin => role == 'admin';
}

