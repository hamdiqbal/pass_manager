class Account {
  final String id;
  final String name;
  final String username;
  final String password;
  final String url;
  final String authenticationKey;
  final String description;
  final String additionalSpace;
  final DateTime createdAt;

  Account({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.url,
    required this.authenticationKey,
    required this.description,
    required this.additionalSpace,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Account copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    String? url,
    String? authenticationKey,
    String? description,
    String? additionalSpace,
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
      additionalSpace: additionalSpace ?? this.additionalSpace,
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
      'additionalSpace': additionalSpace,
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
      additionalSpace: json['additionalSpace'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
