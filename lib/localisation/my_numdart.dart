import 'dart:math';
import 'package:on_sight/error_handling/my_exceptions.dart';

class MyNumDart {
  MyNumDart();

  /// Adds two vector and returns the result.
  ///
  /// Input:
  /// 1) vector1 [List<num>]
  /// 2) vector2 [List<num>]
  ///
  /// Returns:
  /// 1) result [List<num>] - Resultant addition of the two vector.
  List<num> vectorAdd(List<num> vector1, List<num> vector2) {
    assert(vector1.length == vector2.length);

    List<num> result = [];
    for (int i = 0; i < vector1.length; i++) {
      result.add(vector1[i] + vector2[i]);
    }
    return result;
  }

  /// Find the magnitude of the vector.
  ///
  /// Input:
  /// 1) vector [List<num>]
  ///
  /// Returns:
  /// 1) Magnitude of the vector [num].
  num vectorMagnitude(List<num> vector) {
    return sqrt(pow(vector[0], 2).toDouble() + pow(vector[1], 2).toDouble());
  }

  /// Find the roots to a quadratic equation using the quadratic equation.
  ///
  /// Input:
  /// 1) a [num]
  /// 2) b [num]
  /// 3) c [num]
  ///
  /// Results:
  /// 1) Roots [List<num]
  List<num> vectorRoots(num a, num b, num c) {
    List<num> roots = [
      (-b + sqrt((pow(b, 2) - (4 * a * c)))) / (2 * a),
      (-b - sqrt((pow(b, 2) - (4 * a * c)))) / (2 * a)
    ];

    if (roots[0].isNaN || roots[1].isNaN) {
      throw ZeroDivisionError(errMsg: '[vectorRoots]: Zero Division Error');
    }

    return roots;
  }

  /// Convert elements in List to its negative form.
  ///
  /// Input:
  /// 1) array [List<num>].
  ///
  /// Returns:
  /// 1) negativeArray [List<num>].
  List<num> negateList(List<num> array) {
    List<num> negativeArray = [];
    for (int i = 0; i < array.length; i++) {
      negativeArray.add(-array[i]);
    }
    return negativeArray;
  }

  /// Checks if the distance between two vectors are within the threshold limit.
  /// the above equation is not symmetric in a and b – it assumes b is the
  /// reference value – so that isclose(a, b) might be different from
  /// isclose(b, a).
  ///
  /// Furthermore, the default value of atol is not zero, and is used to
  /// determine what small values should be considered close to zero.
  /// The default value is appropriate for expected values of order unity:
  /// if the expected values are significantly smaller than one,
  /// it can result in false positives. atol should be carefully selected for
  /// the use case at hand. A zero value for atol will result in False if
  /// either a or b is zero.
  ///
  /// isclose is not defined for non-numeric data types.
  /// bool is considered a numeric data-type for this purpose.
  /// Reference to:
  /// https://numpy.org/doc/stable/reference/generated/numpy.isclose.html
  ///
  /// Input:
  /// 1) A [num].
  /// 2) B [num].
  /// 3) rtol [num] - relative tolerance parameter (default = 1e-05).
  /// 4) atol [num] - absolute tolerance parameter (default = 1e-08).
  ///
  /// Returns:
  /// 1) result [bool].
  bool isClose(num A, num B, {num rtol = 1e-05, num atol = 1e-08}) {
    num difference = A - B;
    return (difference.abs() <= (atol + rtol * B.abs()));
  }

  /// Logarithmic of the given base.
  /// Reference: https://github.com/dart-lang/sdk/issues/38519
  ///
  /// Input:
  /// 1) x [num]
  /// 2) base [num]
  ///
  /// Returns:
  /// 1) result [num]
  num logBase(num x, num base) {
    return log(x) / log(base);
  }
}
