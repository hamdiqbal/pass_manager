import 'account.dart';

class Subcategory {
  final String id;
  final String name;
  final String additionalField;
  final String description;
  final List<Account> accounts;
  final DateTime createdAt;

  Subcategory({
    required this.id,
    required this.name,
    required this.additionalField,
    required this.description,
    List<Account>? accounts,
    DateTime? createdAt,
  }) : accounts = accounts ?? [],
        createdAt = createdAt ?? DateTime.now();

  Subcategory copyWith({
    String? id,
    String? name,
    String? additionalField,
    String? description,
    List<Account>? accounts,
    DateTime? createdAt,
  }) {
    return Subcategory(
      id: id ?? this.id,
      name: name ?? this.name,
      additionalField: additionalField ?? this.additionalField,
      description: description ?? this.description,
      accounts: accounts ?? this.accounts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'additionalField': additionalField,
      'description': description,
      'accounts': accounts.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Subcategory fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      name: json['name'],
      additionalField: json['additionalField'],
      description: json['description'],
      accounts: (json['accounts'] as List?)
          ?.map((a) => Account.fromJson(a))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
