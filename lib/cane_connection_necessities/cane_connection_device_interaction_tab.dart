import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:functional_data/functional_data.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:provider/provider.dart';

import 'package:on_sight/services/reactive_packages/ble_device_connector.dart';
import 'package:on_sight/services/reactive_packages/onsight_characteristics_interaction_dialogue.dart';
import 'package:on_sight/services/reactive_packages/onsight_ble_device_interactor.dart';
import 'package:on_sight/services/onsight_device_list.dart';

//import '../onsight.dart';

//ignore_for_file: annotate_overrides

//made a copy to edit the package. necessary for cane connection

class CaneConnectionDeviceInteractionTab extends StatelessWidget {
  final DiscoveredDevice device;

  const CaneConnectionDeviceInteractionTab({
    required this.device,
    Key? key,
    required this.onSight,
  }) : super(key: key);

  final OnSight onSight;
  @override
  Widget build(BuildContext context) =>
      Consumer3<BleDeviceConnector, ConnectionStateUpdate, BleDeviceInteractor>(
        builder: (_, deviceConnector, connectionStateUpdate, serviceDiscoverer,
                __) =>
            _CaneConnectionDeviceInteractionTab(
          viewModel: DeviceInteractionViewModel(
              deviceId: device.id,
              connectionStatus: connectionStateUpdate.connectionState,
              deviceConnector: deviceConnector,
              discoverServices: () =>
                  serviceDiscoverer.discoverServices(device.id), onSight: onSight),
              onSight: onSight,
        ),
      );

}

@immutable
@FunctionalData()
class DeviceInteractionViewModel extends $DeviceInteractionViewModel {
  const DeviceInteractionViewModel({
    required this.deviceId,
    required this.connectionStatus,
    required this.deviceConnector,
    required this.discoverServices,
    required this.onSight,
  });

  final OnSight onSight;
  final String deviceId;
  final DeviceConnectionState connectionStatus;
  final BleDeviceConnector deviceConnector;
  @CustomEquality(Ignore())
  final Future<List<DiscoveredService>> Function() discoverServices;

  bool get deviceConnected =>
      connectionStatus == DeviceConnectionState.connected;

  void connect() {
    deviceConnector.connect(deviceId);
  }

  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }
}

class _CaneConnectionDeviceInteractionTab extends StatefulWidget {
  const _CaneConnectionDeviceInteractionTab({
    required this.viewModel,
    Key? key, required this.onSight,
  }) : super(key: key);

  final DeviceInteractionViewModel viewModel;
  final OnSight onSight;
  @override
  _CaneConnectionDeviceInteractionTabState createState() => _CaneConnectionDeviceInteractionTabState(
    onSight: onSight,
  );
}

class _CaneConnectionDeviceInteractionTabState extends State<_CaneConnectionDeviceInteractionTab> {
  _CaneConnectionDeviceInteractionTabState({
    required this.onSight,
  });

  late List<DiscoveredService> discoveredServices;
  late final OnSight onSight;
  //get deviceId => deviceId; //send device ID to navigation page

  //get connectionStatus => connectionStatus; //send connection status to navigation page

  @override
  void initState() {
    discoveredServices = [];
    super.initState();
  }

  Future<void> discoverServices() async {
    final result = await widget.viewModel.discoverServices();
    setState(() {
      discoveredServices = result;
    });
  }

  @override

  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverList(
        delegate: SliverChildListDelegate.fixed(
          [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  top: 8.0, bottom: 16.0, start: 16.0),
              child: Text(
                "ID: ${widget.viewModel.deviceId}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16.0),
              child: Text(
                "Status: ${widget.viewModel.connectionStatus}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: !widget.viewModel.deviceConnected
                        ? widget.viewModel.connect
                        : null,
                    child: const Text("Connect"),
                  ),
                  ElevatedButton(
                    onPressed: widget.viewModel.deviceConnected
                        ? widget.viewModel.disconnect
                        : null,
                    child: const Text("Disconnect"),
                  ),
                  // ElevatedButton(
                  //   onPressed: widget.viewModel.deviceConnected
                  //       ? discoverServices
                  //       : null,
                  //   child: const Text("Discover Services"),
                  // ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OnsightLocalisationScreen(
                              onSight: onSight,
                            ))),
                    child: const Text("Navigate"),
                  ),
                ],
              ),
            ),
            if (widget.viewModel.deviceConnected)
              _ServiceDiscoveryList(
                deviceId: widget.viewModel.deviceId,
                discoveredServices: discoveredServices,
              ),
          ],
        ),
      ),
    ],
  );
}

class _ServiceDiscoveryList extends StatefulWidget {
  const _ServiceDiscoveryList({
    required this.deviceId,
    required this.discoveredServices,
    Key? key,
  }) : super(key: key);

  final String deviceId;
  final List<DiscoveredService> discoveredServices;

  @override
  _ServiceDiscoveryListState createState() => _ServiceDiscoveryListState();
}

class _ServiceDiscoveryListState extends State<_ServiceDiscoveryList> {
  late final List<int> _expandedItems;

  @override
  void initState() {
    _expandedItems = [];
    super.initState();
  }

  String _charactisticsSummary(DiscoveredCharacteristic c) {
    final props = <String>[];
    if (c.isReadable) {
      props.add("read");
    }
    if (c.isWritableWithoutResponse) {
      props.add("write without response");
    }
    if (c.isWritableWithResponse) {
      props.add("write with response");
    }
    if (c.isNotifiable) {
      props.add("notify");
    }
    if (c.isIndicatable) {
      props.add("indicate");
    }

    return props.join("\n");
  }

  Widget _characteristicTile(
          DiscoveredCharacteristic characteristic, String deviceId) =>
      ListTile(
        onTap: () => showDialog<void>(
            context: context,
            builder: (context) => CharacteristicInteractionDialog(
                  characteristic: QualifiedCharacteristic(
                      characteristicId: characteristic.characteristicId,
                      serviceId: characteristic.serviceId,
                      deviceId: deviceId),
                )),
        title: Text(
          '${characteristic.characteristicId}\n(${_charactisticsSummary(characteristic)})',
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      );

  List<ExpansionPanel> buildPanels() {
    final panels = <ExpansionPanel>[];

    widget.discoveredServices.asMap().forEach(
          (index, service) => panels.add(
            ExpansionPanel(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsetsDirectional.only(start: 16.0),
                    child: Text(
                      'Characteristics',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) => _characteristicTile(
                      service.characteristics[index],
                      widget.deviceId,
                    ),
                    itemCount: service.characteristicIds.length,
                  ),
                ],
              ),
              headerBuilder: (context, isExpanded) => ListTile(
                title: Text(
                  '${service.serviceId}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              isExpanded: _expandedItems.contains(index),
            ),
          ),
        );

    return panels;
  }

  @override
  Widget build(BuildContext context) => widget.discoveredServices.isEmpty
      ? const SizedBox()
      : Padding(
          padding: const EdgeInsetsDirectional.only(
            top: 20.0,
            start: 20.0,
            end: 20.0,
          ),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                setState(() {
                  if (isExpanded) {
                    _expandedItems.remove(index);
                  } else {
                    _expandedItems.add(index);
                  }
                });
              });
            },
            children: [
              ...buildPanels(),
            ],
          ),
        );
}


abstract class $DeviceInteractionViewModel {
  const $DeviceInteractionViewModel();
  String get deviceId;
  DeviceConnectionState get connectionStatus;
  BleDeviceConnector get deviceConnector;
  Future<List<DiscoveredService>> Function() get discoverServices;

  get onSight => null;
  DeviceInteractionViewModel copyWith(
      {String? deviceId,
        DeviceConnectionState? connectionStatus,
        BleDeviceConnector? deviceConnector,
        Future<List<DiscoveredService>> Function()? discoverServices}) =>
      DeviceInteractionViewModel(
        deviceId: deviceId ?? this.deviceId,
        connectionStatus: connectionStatus ?? this.connectionStatus,
        deviceConnector: deviceConnector ?? this.deviceConnector,
        discoverServices: discoverServices ?? this.discoverServices, onSight: onSight,); //needed to add onsight cause if not wont work
  @override
  String toString() =>
      "DeviceInteractionViewModel(deviceId: $deviceId, connectionStatus: $connectionStatus, deviceConnector: $deviceConnector, discoverServices: $discoverServices)";
  @override
  bool operator ==(Object other) =>
      other is DeviceInteractionViewModel &&
          other.runtimeType == runtimeType &&
          deviceId == other.deviceId &&
          connectionStatus == other.connectionStatus &&
          deviceConnector == other.deviceConnector &&
          const Ignore().equals(discoverServices, other.discoverServices);
  @override
  int get hashCode {
    var result = 17;
    result = 37 * result + deviceId.hashCode;
    result = 37 * result + connectionStatus.hashCode;
    result = 37 * result + deviceConnector.hashCode;
    result = 37 * result + const Ignore().hash(discoverServices);
    return result;
  }
}

class DeviceInteractionViewModel$ {
  static final deviceId = Lens<DeviceInteractionViewModel, String>(
          (s_) => s_.deviceId, (s_, deviceId) => s_.copyWith(deviceId: deviceId));
  static final connectionStatus =
  Lens<DeviceInteractionViewModel, DeviceConnectionState>(
          (s_) => s_.connectionStatus,
          (s_, connectionStatus) =>
          s_.copyWith(connectionStatus: connectionStatus));
  static final deviceConnector =
  Lens<DeviceInteractionViewModel, BleDeviceConnector>(
          (s_) => s_.deviceConnector,
          (s_, deviceConnector) =>
          s_.copyWith(deviceConnector: deviceConnector));
  static final discoverServices = Lens<DeviceInteractionViewModel,
      Future<List<DiscoveredService>> Function()>(
          (s_) => s_.discoverServices,
          (s_, discoverServices) =>
          s_.copyWith(discoverServices: discoverServices));
}