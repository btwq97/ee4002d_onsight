/// Reference: https://digilent.com/blog/how-to-convert-magnetometer-data-into-compass-heading/
/// Reference: https://cdn-shop.adafruit.com/datasheets/AN203_Compass_Heading_Using_Magnetometers.pdf
/// Reference: https://www.w3.org/TR/magnetometer/ (mainly this)

import 'dart:math';
import 'package:on_sight/error_handling/my_exceptions.dart';

/// Compass Heading
///
/// North, South, East, West, North East, North West, South East, South West.
enum Heading {
  N,
  S,
  E,
  W,
  NE,
  NW,
  SE,
  SW,
}

class Bearing {
  Bearing({
    required Heading heading,
    required num angle,
  })  : heading = heading,
        angle = angle {}

  final Heading heading;
  final num angle;

  String getHeadingString() {
    if (heading == Heading.N)
      return 'North';
    else if (heading == Heading.S)
      return 'South';
    else if (heading == Heading.E)
      return 'East';
    else if (heading == Heading.W)
      return 'West';
    else if (heading == Heading.NE)
      return 'North-East';
    else if (heading == Heading.SE)
      return 'South-East';
    else if (heading == Heading.NW)
      return 'North-West';
    else if (heading == Heading.SW)
      return 'South-West';
    else
      return '';
  }

  String getAngleString() {
    return angle.toString();
  }
}

class Compass {
  Compass({
    required num magx,
    required num magy,
  })  : _magx = magx,
        _magy = magy {
    _bearing = _findBearing();
  }

  final num _magx;
  final num _magy;

  late Bearing _bearing;

  /// Sensorplus reading is from -180 to 180, creating a one whole circle
  Bearing _findBearing() {
    num tempAngle = atan2(_magy, _magx) * (180 / pi);
    num angle = _calibrate(tempAngle);

    // If D is greater than 337.25 degrees or less than 22.5 degrees – North
    if (angle < 22.5 || angle >= 337.25) {
      return Bearing(heading: Heading.N, angle: angle);
    }
    // If D is between 292.5 degrees and 337.25 degrees – North-West
    else if (angle < 337.25 && angle >= 292.5) {
      return Bearing(heading: Heading.NW, angle: angle);
    }
    // If D is between 247.5 degrees and 292.5 degrees – West
    else if (angle < 292.5 && angle >= 247.5) {
      return Bearing(heading: Heading.W, angle: angle);
    }
    // If D is between 202.5 degrees and 247.5 degrees – South-West
    else if (angle < 247.5 && angle >= 202.5) {
      return Bearing(heading: Heading.SW, angle: angle);
    }
    // If D is between 157.5 degrees and 202.5 degrees – South
    else if (angle < 202.5 && angle >= 157.5) {
      return Bearing(heading: Heading.S, angle: angle);
    }
    // If D is between 112.5 degrees and 157.5 degrees – South-East
    else if (angle < 157.5 && angle >= 112.5) {
      return Bearing(heading: Heading.SE, angle: angle);
    }
    // If D is between 67.5 degrees and 112.5 degrees – East
    else if (angle < 112.5 && angle >= 67.5) {
      return Bearing(heading: Heading.E, angle: angle);
    }
    // If D is between 0 degrees and 67.5 degrees – North-East
    else if (angle < 67.5 && angle >= 22.5) {
      return Bearing(heading: Heading.NE, angle: angle);
    }
    // catch error
    else {
      throw NoPossibleSolution(
          errMsg: "[_getHeading()]: Unable to find bearing!");
    }
  }

  Bearing getBearing() {
    return _bearing;
  }

  /// Calibrate magnetometer readings.
  ///
  /// How to calibrate?
  /// 1) Uncomment line 142.
  /// 2) Compare readings with a compass and find offset.
  /// 3) Compass is now calibrated.
  ///
  /// Inputs:
  /// 1) rawAngle [num] - unedited angle value.
  ///
  /// Return:
  /// 1) calibratedAngle [num] - calibrated angle value (in degree).
  num _calibrate(num rawAngle) {
    num offset = 100.0; // based on calibration with iPhone 12 mini
    num calibratedAngle = rawAngle;

    // convert to all positive bearings
    if (rawAngle < 0.0) {
      calibratedAngle += 360.0;
    }

    // calibration to iphone 12 mini
    calibratedAngle -= offset; // TODO: comment here to calibrate
    // convert to all positive bearings
    if (calibratedAngle < 0.0) {
      calibratedAngle += 360.0;
    }

    return calibratedAngle;
  }
}
