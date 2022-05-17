
Iterable<E> enumerate<E, T>(
    Iterable<T> items, E Function(int index, T item) f) {
  var index = 0;
  return items.map((item) {
    final result = f(index, item);
    index = index + 1;
    return result;
  });
}