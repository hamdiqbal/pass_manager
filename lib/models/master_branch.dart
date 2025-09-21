import 'custom_field.dart';
import 'subcategory.dart';

class MasterBranchModel {
  final String id;
  final String name;
  final String description;
  final String additionalField;
  final List<CustomField> customFields;
  final List<Subcategory> subcategories;
  final DateTime createdAt;

  MasterBranchModel({
    required this.id,
    required this.name,
    required this.description,
    required this.additionalField,
    List<CustomField>? customFields,
    List<Subcategory>? subcategories,
    DateTime? createdAt,
  }) : customFields = customFields ?? <CustomField>[],
        subcategories = subcategories ?? <Subcategory>[],
        createdAt = createdAt ?? DateTime.now();

  MasterBranchModel copyWith({
    String? id,
    String? name,
    String? description,
    String? additionalField,
    List<CustomField>? customFields,
    List<Subcategory>? subcategories,
    DateTime? createdAt,
  }) {
    return MasterBranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      additionalField: additionalField ?? this.additionalField,
      customFields: customFields ?? this.customFields,
      subcategories: subcategories ?? this.subcategories,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'additionalField': additionalField,
      'customFields': customFields.map((f) => f.toJson()).toList(),
      'subcategories': subcategories.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static MasterBranchModel fromJson(Map<String, dynamic> json) {
    return MasterBranchModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      additionalField: json['additionalField'] ?? '',
      customFields: (json['customFields'] as List?)
          ?.map((f) => CustomField.fromJson(f))
          .toList() ?? <CustomField>[],
      subcategories: (json['subcategories'] as List?)
          ?.map((s) => Subcategory.fromJson(s))
          .toList() ?? <Subcategory>[],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Alias for compatibility
typedef MasterBranch = MasterBranchModel;
