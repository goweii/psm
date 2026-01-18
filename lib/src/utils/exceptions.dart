/// Custom exception class for providing user-friendly error messages
class TipsException implements Exception {
  /// Error message describing the exception
  final String message;

  /// Creates a new instance of [TipsException] with the specified message
  TipsException(this.message);

  @override
  String toString() {
    return message;
  }
}
