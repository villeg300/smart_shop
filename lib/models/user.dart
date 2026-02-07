class User {
  final int id;
  final String phoneNumber;
  final String fullName;
  final String email;
  final int loyaltyPoints;
  final DateTime dateJoined;
  final String? avatar; // Pour plus tard

  const User({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.email,
    required this.loyaltyPoints,
    required this.dateJoined,
    this.avatar,
  });

  /// Créer un User depuis la réponse JSON de l'API
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      phoneNumber: json['phone_number'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      loyaltyPoints: json['loyalty_points'] as int? ?? 0,
      dateJoined: DateTime.parse(json['date_joined'] as String),
      avatar: json['avatar'] as String?,
    );
  }

  /// Convertir User en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'email': email,
      'loyalty_points': loyaltyPoints,
      'date_joined': dateJoined.toIso8601String(),
      if (avatar != null) 'avatar': avatar,
    };
  }

  /// Créer une copie avec certains champs modifiés
  User copyWith({
    int? id,
    String? phoneNumber,
    String? fullName,
    String? email,
    int? loyaltyPoints,
    DateTime? dateJoined,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      dateJoined: dateJoined ?? this.dateJoined,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, fullName: $fullName, phone: $phoneNumber, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
