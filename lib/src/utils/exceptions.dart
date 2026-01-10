class TipsException implements Exception {
  final String message;

  TipsException(this.message);

  @override
  String toString() {
    return message;
  }
}
