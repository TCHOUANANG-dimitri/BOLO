class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String? location;
  final bool isProvider;
  final DateTime createdAt;
  final List<String> favoriteProviderIds;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.location,
    required this.isProvider,
    required this.createdAt,
    this.favoriteProviderIds = const [],
  });

  String get firstName => fullName.split(' ').first;
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? location,
    List<String>? favoriteProviderIds,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      isProvider: isProvider,
      createdAt: createdAt,
      favoriteProviderIds: favoriteProviderIds ?? this.favoriteProviderIds,
    );
  }
}
