class httpExcptions implements Exception{
  final String message;

  httpExcptions(this.message);
  @override
  String toString() {
    return message;
  }

}