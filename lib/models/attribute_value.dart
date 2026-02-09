class AttributeValue {
  final String id;
  final String attribute;
  final String attributeName;
  final String value;

  AttributeValue({
    required this.id,
    required this.attribute,
    required this.attributeName,
    required this.value,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      id: json['id'] as String,
      attribute: json['attribute'] as String,
      attributeName: json['attribute_name'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attribute': attribute,
      'attribute_name': attributeName,
      'value': value,
    };
  }

  @override
  String toString() => '$attributeName: $value';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttributeValue && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
