
/// An [Error] that holds a message to print.
class PrintableError extends Error {
  final String message;

  PrintableError(this.message);

  @override
  String toString() => message;
}
