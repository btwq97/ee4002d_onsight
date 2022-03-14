import 'dart:async';
import 'dart:collection';
import 'package:meta/meta.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:on_sight/services/reactive_packages/reactive_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import 'package:on_sight/services/reactive_packages/widgets.dart';
import 'package:on_sight/services/onsight_scanner.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/localisation/localisation.dart';

import 'package:on_sight/navigations/compass.dart';



class DirectionSender{

  //commented out to commit to git without any issues
  // final characteristic = QualifiedCharacteristic(serviceId: serviceUuid, characteristicId: characteristicUuid, deviceId: foundDeviceId);
  //
  // static get serviceUuid => "6E400001-B5A3-F393-E0A9-E50E24DCCA9"; //for the current ESp32 that is used
  // static get characteristicUuid => "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; //for the current ESp32 that is used
  // static get foundDeviceId => "AC:67:B2:2B:0F:A6"; //Current ESP32 ID
  //
  //
  // String _sendDirectionToCaneFromPhone(DiscoveredCharacteristic c) {
  //   final props = <String>[];
  //
  //   if (c.isWritableWithoutResponse) {
  //
  //   }
  //   if (c.isWritableWithResponse) {
  //     props.add("write with response");
  //   }
  //   if (c.isNotifiable) {
  //     props.add("notify");
  //   }
  //   if (c.isIndicatable) {
  //     props.add("indicate");
  //   }
  //
  //   return props.join("\n");
  // }

  //if (tempDirection['suggested_direction'] == ){}
}