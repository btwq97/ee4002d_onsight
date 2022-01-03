import 'dart:math';

class MyNumDart {
  MyNumDart();

  /// Adds two vector and returns the result.
  ///
  /// Input:
  /// 1) vector1 [List<double>]
  /// 2) vector2 [List<double>]
  ///
  /// Returns:
  /// 1) result [List<double>] - Resultant addition of the two vector.
  List<double> vectorAdd(List<double> vector1, List<double> vector2) {
    assert(vector1.length == vector2.length);

    List<double> result = [];
    for (int i = 0; i < vector1.length; i++) {
      result.add(vector1[i] + vector2[i]);
    }
    return result;
  }

  /// Find the magnitude of the vector.
  ///
  /// Input:
  /// 1) vector [List<double>]
  ///
  /// Returns:
  /// 1) Magnitude of the vector [double].
  double vectorMagnitude(List<double> vector) {
    return sqrt(pow(vector[0], 2).toDouble() + pow(vector[1], 2).toDouble());
  }

  /// Find the roots to a quadratic equation using the quadratic equation.
  ///
  /// Input:
  /// 1) a [double]
  /// 2) b [double]
  /// 3) c [double]
  ///
  /// Results:
  /// 1) Roots [List<double]
  List<double> vectorRoots(double a, double b, double c) {
    List<double> roots = [
      (-b + sqrt((pow(b, 2) - (4 * a * c)))) / (2 * a),
      (-b - sqrt((pow(b, 2) - (4 * a * c)))) / (2 * a)
    ];

    return roots;
  }

  /// Convert elements in List to its negative form.
  ///
  /// Input:
  /// 1) array [List<double>].
  ///
  /// Returns:
  /// 1) negativeArray [List<double>].
  List<double> negateList(List<double> array) {
    List<double> negativeArray = [];
    for (int i = 0; i < array.length; i++) {
      negativeArray.add(-array[i]);
    }
    return negativeArray;
  }

  /// Checks if the distance between two vectors are within the threshold limit.
  /// Reference to:
  /// https://numpy.org/doc/stable/reference/generated/numpy.isclose.html
  ///
  /// Input:
  /// 1) A [double].
  /// 2) B [double].
  ///
  /// Returns:
  /// 1) result [bool].
  bool isClose(double A, double B) {
    double rtol = 1e-05;
    double atol = 1e-08;
    double difference = A - B;
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
