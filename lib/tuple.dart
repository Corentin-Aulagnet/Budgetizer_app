class Tuple<T1, T2> {
  final T1 _first;
  final T2 _second;
  const Tuple(this._first, this._second);

  T1 get first => _first;
  T2 get second => _second;
}
