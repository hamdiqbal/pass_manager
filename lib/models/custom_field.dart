class CustomField {
  final String id;
  final String name;
  final String type; // text, boolean, hidden, linked
  final dynamic value;

  CustomField({
    required this.id,
    required this.name,
    required this.type,
    this.value,
  });

  CustomField copyWith({
    String? id,
    String? name,
    String? type,
    dynamic value,
  }) {
    return CustomField(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
    };
  }

  static CustomField fromJson(Map<String, dynamic> json) {
    return CustomField(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      value: json['value'],
    );
  }
}