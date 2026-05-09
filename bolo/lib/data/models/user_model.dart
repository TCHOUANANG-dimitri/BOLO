class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String? location;
  final bool isProvider;
  final bool twoFactorEnabled;
  final DateTime createdAt;
  final List<String> favoriteProviderIds;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.location,
    this.isProvider = false,
    this.twoFactorEnabled = false,
    required this.createdAt,
    this.favoriteProviderIds = const [],
  });

  String get firstName => fullName.split(' ').first;

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  // ─── Local DB ─────────────────────────────────────────────────────────────

  factory UserModel.fromLocal(Map<String, dynamic> data) {
    DateTime createdAt = DateTime.now();
    final rawDate = data['createdAt'];
    if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is DateTime) {
      createdAt = rawDate;
    }

    return UserModel(
      id: data['id'] ?? '',
      fullName: data['fullName'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      avatarUrl: data['avatarUrl'],
      location: data['location'],
      isProvider: data['isProvider'] ?? false,
      twoFactorEnabled: data['twoFactorEnabled'] ?? false,
      createdAt: createdAt,
      favoriteProviderIds:
          List<String>.from(data['favoriteProviderIds'] ?? []),
    );
  }

  // Alias pour la compatibilité avec les repositories existants
  factory UserModel.fromFirestore(Map<String, dynamic> data) =>
      UserModel.fromLocal(data);

  Map<String, dynamic> toLocal() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'location': location,
        'isProvider': isProvider,
        'twoFactorEnabled': twoFactorEnabled,
        'createdAt': createdAt.toIso8601String(),
        'favoriteProviderIds': favoriteProviderIds,
      };

  // Alias pour la compatibilité
  Map<String, dynamic> toFirestore() => toLocal();

  // ─── copyWith ─────────────────────────────────────────────────────────────

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? location,
    bool? twoFactorEnabled,
    List<String>? favoriteProviderIds,
  }) =>
      UserModel(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        location: location ?? this.location,
        isProvider: isProvider,
        twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
        createdAt: createdAt,
        favoriteProviderIds: favoriteProviderIds ?? this.favoriteProviderIds,
      );
}
