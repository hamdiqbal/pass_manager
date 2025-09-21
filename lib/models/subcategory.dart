import 'account.dart';
import 'custom_field.dart';

class Subcategory {
  final String id;
  final String name;
  final String description;
  final List<CustomField> customFields;
  final List<Account> accounts;
  final DateTime createdAt;

  Subcategory({
    required this.id,
    required this.name,
    required this.description,
    List<CustomField>? customFields,
    List<Account>? accounts,
    DateTime? createdAt,
  }) : customFields = customFields ?? [],
        accounts = accounts ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Legacy getter for compatibility with existing code
  String get additionalField {
    final textField = customFields.firstWhere(
      (field) => field.type == 'text',
      orElse: () => CustomField(id: '', name: '', type: 'text', value: ''),
    );
    return textField.value?.toString() ?? '';
  }

  Subcategory copyWith({
    String? id,
    String? name,
    String? description,
    List<CustomField>? customFields,
    List<Account>? accounts,
    DateTime? createdAt,
  }) {
    return Subcategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      customFields: customFields ?? this.customFields,
      accounts: accounts ?? this.accounts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'customFields': customFields.map((f) => f.toJson()).toList(),
      'accounts': accounts.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Subcategory fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      customFields: (json['customFields'] as List?)
          ?.map((f) => CustomField.fromJson(f))
          .toList() ?? [],
      accounts: (json['accounts'] as List?)
          ?.map((a) => Account.fromJson(a))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
