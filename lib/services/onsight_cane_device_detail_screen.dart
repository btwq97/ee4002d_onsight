import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/services/reactive_packages/ble_device_connector.dart';
import 'package:on_sight/services/reactive_packages/device_log_tab.dart';
import 'package:provider/provider.dart';

import 'onsight_cane_device_interaction_tab_ui.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DiscoveredDevice device;
  final OnSight onSight;

  const DeviceDetailScreen({
    required this.device,
    required this.onSight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<BleDeviceConnector>(
        builder: (_, deviceConnector, __) => _DeviceDetail(
          onSight: onSight,
          device: device,
          disconnect: deviceConnector.disconnect,
        ),
      );
}

class _DeviceDetail extends StatelessWidget {
  const _DeviceDetail({
    required this.device,
    required this.disconnect,
    required this.onSight,
    Key? key,
  }) : super(key: key);

  final OnSight onSight;
  final DiscoveredDevice device;
  final void Function(String deviceId) disconnect;
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          disconnect(device.id);
          return true;
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(device.name),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.bluetooth_connected,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.find_in_page_sharp,
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                DeviceInteractionTab(
                  onSight: onSight,
                  device: device,
                ),
                const DeviceLogTab(),
              ],
            ),
          ),
        ),
      );
}
