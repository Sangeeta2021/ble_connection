import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class Home4 extends StatefulWidget {
  @override
  _Home4State createState() => _Home4State();
}

class _Home4State extends State<Home4> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? weightCharacteristic;
  String weight = "0.0"; // Placeholder for the weight data

  @override
  void initState() {
    super.initState();
    requestPermissions();
    startScan();
  }

  Future<void> requestPermissions() async {
    var status = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (status[Permission.bluetooth]!.isGranted &&
        status[Permission.bluetoothScan]!.isGranted &&
        status[Permission.bluetoothConnect]!.isGranted &&
        status[Permission.locationWhenInUse]!.isGranted) {
      print("All permissions granted");
    } else {
      print("Permissions not granted");
    }
  }

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 5));

    flutterBlue.scanResults.listen((results) {
      setState(() {
        devicesList = results.map((r) => r.device).toList();
      });
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
    print("Connected to ${device.name}");
    await discoverServices(device);
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (_isWeightCharacteristic(characteristic)) {
          weightCharacteristic = characteristic;
          _subscribeToWeightNotifications(characteristic);
          print("Subscribed to weight notifications.");
        }
      }
    }
  }

  // Function to check if the characteristic is the weight characteristic
  bool _isWeightCharacteristic(BluetoothCharacteristic characteristic) {
    //need to add our weight machine uuid
    const weightCharacteristicUUID = 'your_weight_characteristic_uuid_here';
    return characteristic.uuid.toString() == weightCharacteristicUUID;
  }

  void _subscribeToWeightNotifications(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    characteristic.value.listen((value) {
      setState(() {
        weight = _parseWeight(value);
      });
      print("Weight received: $weight");
    });
  }

  // Function to parse weight from raw  data
  String _parseWeight(List<int> value) {
    // Assuming weight is sent in simple bytes, you may convert them to a number like:
    double parsedWeight = value[0] + (value[1] << 8).toDouble(); // Example of parsing bytes
    return parsedWeight.toString();
  }

  void disconnectDevice() {
    if (connectedDevice != null) {
      connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
        weight = "0.0"; // Reset the weight
      });
      print("Disconnected from device");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade100,
        title: Text('BLE Weight Machine'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: Colors.purple.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    title: Text(devicesList[index].name.isEmpty
                        ? 'Unknown Device'
                        : devicesList[index].name),
                    subtitle: Text(devicesList[index].id.toString()),
                    onTap: () => connectToDevice(devicesList[index]),
                  ),
                );
              },
            ),
          ),
          if (connectedDevice != null)
            Column(
              children: [
                Text(
                  'Connected to ${connectedDevice!.name}',//Display connected debice name
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                  'Weight: $weight kg', // Display the weight on the screen
                  style: TextStyle(fontSize: 50),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: disconnectDevice,
                  child: Text('Disconnect'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}