class TileException implements Exception {
  TileException({required String errMsg}) : errMsg = errMsg;
  final String errMsg;

  String what() {
    return errMsg;
  }
}
