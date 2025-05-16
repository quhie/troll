import 'sound_category.dart';

/// Model representing a sound effect
class SoundModel {
  final String id;
  final String name;
  final String soundPath;
  final String iconName;
  final CategoryType category;
  final bool isFavorite;
  final bool isLocal;

  const SoundModel({
    required this.id,
    required this.name,
    required this.soundPath,
    required this.iconName,
    required this.category,
    this.isFavorite = false,
    this.isLocal = false,
  });

  /// Create a copy of this sound with modified properties
  SoundModel copyWith({
    String? id,
    String? name,
    String? soundPath,
    String? iconName,
    CategoryType? category,
    bool? isFavorite,
    bool? isLocal,
  }) {
    return SoundModel(
      id: id ?? this.id,
      name: name ?? this.name,
      soundPath: soundPath ?? this.soundPath,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  /// Create from JSON data
  factory SoundModel.fromJson(Map<String, dynamic> json) {
    return SoundModel(
      id: json['id'] as String,
      name: json['name'] as String,
      soundPath: json['soundPath'] as String,
      iconName: json['iconName'] as String,
      category: CategoryType.values[json['category'] as int],
      isFavorite: json['isFavorite'] as bool? ?? false,
      isLocal: json['isLocal'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'soundPath': soundPath,
      'iconName': iconName,
      'category': category.index,
      'isFavorite': isFavorite,
      'isLocal': isLocal,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
