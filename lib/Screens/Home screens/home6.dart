//we are collecting the device uid via code & added connect button logic

import 'package:bluetooth_connect/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class Home6 extends StatefulWidget {
  const Home6({super.key});

  @override
  State<Home6> createState() => _Home6State();
}

class _Home6State extends State<Home6> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> deviceList = [];
  Map<String, BluetoothDevice> connectedDevices = {};
  Map<String, String> serviceUUIDs = {}; // for storin uuid
  Map<String, String> characteristicUUIDs = {}; //for storing charastic uuid
  BluetoothCharacteristic? targetCharacteristic;
  String? deviceWeight;
  BluetoothDevice? connectedDevice;

  @override
  void initState() {
    super.initState();
    checkPermission();
    startScan();
  }

  Future<void> checkPermission() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!deviceList.contains(result.device)) {
          setState(() {
            deviceList.add(result.device);
          });
        }
      }
    });
    flutterBlue.stopScan();
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevices[device.id.id] = device;
    });
    discoverServices(device);
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        // Check for properties like read, write, notify to identify target characteristic
        if (characteristic.properties.notify) {
          setState(() {
            serviceUUIDs[device.id.id] = service.uuid.toString();
            characteristicUUIDs[device.id.id] = characteristic.uuid.toString();
            targetCharacteristic = characteristic;
          });
          characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            parseData(value);
          });
        }
      }
    }
  }

  void parseData(List<int> value) {
    // Parsing data from bytes, assuming data format is compatible with weight data

    setState(() {
      deviceWeight = String.fromCharCodes(value);
    });
  }

  void disconnectDevice(BluetoothDevice device) async {
    await device.disconnect();
    setState(() {
      connectedDevices.remove(device.id.id);
      serviceUUIDs.remove(device.id.id);
      characteristicUUIDs.remove(device.id.id);
    });
  }

  Widget buildDeviceList() {
    return ListView.builder(
        itemCount: deviceList.length,
        itemBuilder: (context, index) {
          var device = deviceList[index];
          bool isConnected = connectedDevices.containsKey(device.id.id);
          return ListTile(
            tileColor: themeColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(device.name.isEmpty ? device.name : "Unknown Device"),
            subtitle: Text(device.id.id),
            trailing: ElevatedButton(
              onPressed: () {
                isConnected
                    ? disconnectDevice(device)
                    : connectToDevice(device);
              },
              child: Text(isConnected ? "Dixconnect" : "Connect"),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BLE Connection"),
        backgroundColor: themeColor,
      ),
      body: Column(
        children: [
          Expanded(child: buildDeviceList()),
          if(deviceWeight != null)...[
            Text("Weight: $deviceWeight kg"),
          ]
        ],
      ),
    );
  }
}
