extension ListX<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    final l = where(test);
    if (l.isNotEmpty) {
      return l.first;
    }
    return null;
  }

  (T, int) firstWhereIndexed(bool Function(T element) predicate) {
    for (int i = 0; i < length; i++) {
      final element = elementAt(i);
      if (predicate(element)) {
        return (element, i);
      }
    }
    throw RangeError('Element matching predicate not in collection.');
  }
}
