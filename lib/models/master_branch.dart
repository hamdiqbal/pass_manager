import 'subcategory.dart';

class MasterBranch {
  final String id;
  final String name;
  final String additionalField;
  final String description;
  final List<Subcategory> subcategories;
  final DateTime createdAt;

  MasterBranch({
    required this.id,
    required this.name,
    required this.additionalField,
    required this.description,
    List<Subcategory>? subcategories,
    DateTime? createdAt,
  }) : subcategories = subcategories ?? [],
        createdAt = createdAt ?? DateTime.now();

  MasterBranch copyWith({
    String? id,
    String? name,
    String? additionalField,
    String? description,
    List<Subcategory>? subcategories,
    DateTime? createdAt,
  }) {
    return MasterBranch(
      id: id ?? this.id,
      name: name ?? this.name,
      additionalField: additionalField ?? this.additionalField,
      description: description ?? this.description,
      subcategories: subcategories ?? this.subcategories,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'additionalField': additionalField,
      'description': description,
      'subcategories': subcategories.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static MasterBranch fromJson(Map<String, dynamic> json) {
    return MasterBranch(
      id: json['id'],
      name: json['name'],
      additionalField: json['additionalField'],
      description: json['description'],
      subcategories: (json['subcategories'] as List?)
          ?.map((s) => Subcategory.fromJson(s))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
