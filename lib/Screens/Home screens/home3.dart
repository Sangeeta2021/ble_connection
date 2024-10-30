import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class Home3 extends StatefulWidget {
  @override
  _Home3State createState() => _Home3State();
}

class _Home3State extends State<Home3> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];

  @override
  void initState() {
    super.initState();
    checkBluetoothStatus();
    requestPermission();
  }
// for checking status of the bluetooth
  void checkBluetoothStatus() async {
    var bluetoothState = await flutterBlue.state.first;
    if (bluetoothState == BluetoothState.off) {
      print("Bluetooth is off. Please on it");
    } else {
      startScan();
    }
  }
//for requesting permissions
  void requestPermission() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse
    ].request();
  }
//for scan the device
  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen for scan results
    flutterBlue.scanResults.listen((results) {
      setState(() {
        _devicesList = results.map((r) => r.device).toList();
      });
    });
  }

//for connect to the device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      print('Connecting to device...');
      await device.connect();
      setState(() {
        _connectedDevice = device;
      });
      print('Connected to ${device.name}');

      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      setState(() {
        _services = services;
      });
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }
//for disconnect the device
  void disconnectDevice() {
    if (_connectedDevice != null) {
      _connectedDevice!.disconnect();
      setState(() {
        _connectedDevice = null;
      });
      print("Disconnected from device");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Weight Machine'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: _devicesList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_devicesList[index].name.isEmpty
                        ? "Unknown Device"
                        : _devicesList[index].name),
                    subtitle: Text(_devicesList[index].id.toString()),
                    onTap: () {
                      connectToDevice(_devicesList[index]);
                    },
                  );
                }),
          ),
          if (_connectedDevice != null)
            ElevatedButton(
                onPressed: () {},
                child: Text("Disconnect From ${_connectedDevice!.name}"))
        ],
      ),
    );
  }
//for creating the available device list
  Widget _buildDeviceList() {
    if (_devicesList.isEmpty) {
      return Center(child: Text('No devices found'));
    }

    return ListView.builder(
      itemCount: _devicesList.length,
      itemBuilder: (context, index) {
        BluetoothDevice device = _devicesList[index];
        return ListTile(
          title: Text(device.name.isEmpty ? 'Unknown device' : device.name),
          subtitle: Text(device.id.toString()),
          onTap: () {
            connectToDevice(device);
          },
        );
      },
    );
  }
//for creating the available service list
  Widget _buildServiceTiles() {
    if (_services.isEmpty) {
      return Center(child: Text('No services found'));
    }

    return ListView(
      children: _services.map((service) {
        return ListTile(
          title: Text('Service UUID: ${service.uuid}'),
        );
      }).toList(),
    );
  }
}
