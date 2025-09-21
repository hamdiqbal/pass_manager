import 'custom_field.dart';

class Account {
  final String id;
  final String name;
  final String username;
  final String password;
  final String url;
  final String authenticationKey;
  final String description;
  final List<CustomField> customFields;
  final DateTime createdAt;

  Account({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.url,
    required this.authenticationKey,
    required this.description,
    List<CustomField>? customFields,
    DateTime? createdAt,
  }) : customFields = customFields ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Legacy getter for compatibility with existing code
  String get additionalSpace {
    final textField = customFields.firstWhere(
      (field) => field.type == 'text',
      orElse: () => CustomField(id: '', name: '', type: 'text', value: ''),
    );
    return textField.value?.toString() ?? '';
  }

  Account copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    String? url,
    String? authenticationKey,
    String? description,
    List<CustomField>? customFields,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      authenticationKey: authenticationKey ?? this.authenticationKey,
      description: description ?? this.description,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'url': url,
      'authenticationKey': authenticationKey,
      'description': description,
      'customFields': customFields.map((f) => f.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Account fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      password: json['password'],
      url: json['url'],
      authenticationKey: json['authenticationKey'],
      description: json['description'],
      customFields: (json['customFields'] as List?)
          ?.map((f) => CustomField.fromJson(f))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
