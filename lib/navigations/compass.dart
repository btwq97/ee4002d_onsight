/// Reference: https://digilent.com/blog/how-to-convert-magnetometer-data-into-compass-heading/
/// Reference: https://cdn-shop.adafruit.com/datasheets/AN203_Compass_Heading_Using_Magnetometers.pdf
/// Reference: https://www.w3.org/TR/magnetometer/ (mainly this)

import 'dart:math';
import 'package:on_sight/error_handling/my_exceptions.dart';

enum Headings {
  N,
  S,
  E,
  W,
  NE,
  SE,
  SW,
  NW,
}

class Compass {
  Compass({
    required num magx,
    required num magy,
    required num magz,
  })  : _magx = magx,
        _magy = magy,
        _magz = magz {
    _headings = _getHeading();
  }

  final num _magx;
  final num _magy;
  final num _magz;
  late Headings _headings;

  /// Sensorplus reading is from -180 to 180, creating a one whole circle
  Headings _getHeading() {
    num tempHeading = atan2(_magy, _magx) * (180 / pi);
    num heading = calibrate(tempHeading);

    print('Heading in Degree: $heading');

    // If D is greater than 337.25 degrees or less than 22.5 degrees – North
    if (heading <= 22.5 || heading >= 337.25) {
      return Headings.N;
    }
    // If D is between 292.5 degrees and 337.25 degrees – North-West
    else if (heading <= 337.25 && heading >= 292.5) {
      return Headings.NW;
    }
    // If D is between 247.5 degrees and 292.5 degrees – West
    else if (heading <= 292.5 && heading >= 247.5) {
      return Headings.W;
    }
    // If D is between 202.5 degrees and 247.5 degrees – South-West
    else if (heading <= 247.5 && heading >= 202.5) {
      return Headings.SW;
    }
    // If D is between 157.5 degrees and 202.5 degrees – South
    else if (heading <= 202.5 && heading >= 157.5) {
      return Headings.S;
    }
    // If D is between 112.5 degrees and 157.5 degrees – South-East
    else if (heading <= 157.5 && heading >= 112.5) {
      return Headings.SE;
    }
    // If D is between 67.5 degrees and 112.5 degrees – East
    else if (heading <= 112.5 && heading >= 67.5) {
      return Headings.E;
    }
    // If D is between 0 degrees and 67.5 degrees – North-East
    else if (heading <= 67.5 && heading >= 0) {
      return Headings.NE;
    }
    // catch error
    else {
      throw NoPossibleSolution(
          errMsg: "[_getHeading()]: Unable to find bearing!");
    }
  }

  num toNum() {
    if (_headings == Headings.N) {
      return 1.0;
    } else if (_headings == Headings.S) {
      return 2.0;
    } else if (_headings == Headings.E) {
      return 3.0;
    } else if (_headings == Headings.W) {
      return 4.0;
    } else if (_headings == Headings.NE) {
      return 5.0;
    } else if (_headings == Headings.SE) {
      return 6.0;
    } else if (_headings == Headings.SW) {
      return 7.0;
    } else if (_headings == Headings.NW) {
      return 8.0;
    } else {
      throw NoPossibleSolution(errMsg: "[toInt()]: No possible bearing found");
    }
  }

  num calibrate(num rawHeading) {
    /// How to calibrate?
    /// 1) Uncomment line 118.
    /// 2) Compare readings with a compass and find offset.
    /// 3) Compass is now calibrated.

    num offset = 100; // based on calibration with iPhone 12 mini
    num calibratedHeading = rawHeading;

    // convert to all positive bearings
    if (rawHeading < 0) {
      calibratedHeading += 360;
    }

    // calibration to iphone 12 mini
    calibratedHeading -= offset;
    // convert to all positive bearings
    if (calibratedHeading < 0) {
      calibratedHeading += 360;
    }

    return calibratedHeading;
  }
}
