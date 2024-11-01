
//if we clcik on any device navigate  to another screen


import 'package:bluetooth_connect/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

import '../device_screen.dart';

class Home5 extends StatefulWidget {
  const Home5({super.key});

  @override
  _Home5State createState() => _Home5State();
}

class _Home5State extends State<Home5> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];

  @override
  void initState() {
    super.initState();
    requestPermissions();
    startScan();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    flutterBlue.scanResults.listen((results) {
      setState(() {
        devicesList = results.map((r) => r.device).toList();
      });
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceScreen(device: device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text('Available Devices'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devicesList[index].name.isEmpty
                      ? 'Unknown Device'
                      : devicesList[index].name),
                  subtitle: Text(devicesList[index].id.toString()),
                  onTap: () => connectToDevice(devicesList[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}