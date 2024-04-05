class EventCategory<T> {
  final String id;
  final List<T> values;
  EventCategory({
    required this.id,
    required this.values,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventCategory && other.id == id && other.values == values;
  }

  @override
  int get hashCode => id.hashCode ^ values.hashCode;

  @override
  String toString() => 'EventCategory(id: $id, value: $values)';
}
