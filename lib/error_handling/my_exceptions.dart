class TileException implements Exception {
  TileException({required String errMsg}) : errMsg = errMsg;
  final String errMsg;

  String what() {
    return errMsg;
  }
}

class NoPossibleSolution implements Exception {
  NoPossibleSolution({required String errMsg}) : errMsg = errMsg;
  final String errMsg;

  String what() {
    return errMsg;
  }
}

class ZeroDivisionError implements Exception {
  ZeroDivisionError({required String errMsg}) : errMsg = errMsg;
  final String errMsg;

  String what() {
    return errMsg;
  }
}
