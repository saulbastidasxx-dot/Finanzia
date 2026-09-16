class UserProfile {
  final String name;
  final String email;
  final String currency;
  const UserProfile({
    required this.name,
    required this.email,
    this.currency = 'USD',
  });
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'currency': currency,
  };
  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    name: j['name'] ?? 'Usuario',
    email: j['email'] ?? '',
    currency: j['currency'] ?? 'USD',
  );
  UserProfile copyWith({String? name, String? email, String? currency}) =>
      UserProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        currency: currency ?? this.currency,
      );
}
