import 'package:bluetooth_connect/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  DeviceScreen({required this.device});

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  String weight = "0.0";

  @override
  void initState() {
    super.initState();
    discoverServices();
  }

  Future<void> discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        //we need to pass our uuid of our weight value given by the device
        if (characteristic.uuid.toString() == 'WEIGHT_CHARACTERISTIC_UUID') {
          await characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            setState(() {
              weight = _parseWeight(value);
            });
          });
        }
      }
    }
  }

  String _parseWeight(List<int> value) {
    double parsedWeight = value[0] + (value[1] << 8).toDouble();
    return parsedWeight.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text('Weight Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Weight: $weight kg', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.device.disconnect();
                Navigator.pop(context);
              },
              child: Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}