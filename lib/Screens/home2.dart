import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? weightCharacteristic;
  String weight = "Not Connected";

  @override
  void initState() {
    super.initState();
    scanForDevices();
  }

//for scanning device
  void scanForDevices() {
    flutterBlue.startScan(timeout: Duration(seconds: 5));

    //listen to scan results
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        print("Device Found: ${r.device.name} with RSSI: ${r.rssi}");
        if (r.device.name == "Your_Scale") {
          //stop scan
          flutterBlue.stopScan();
          connectToDevice(r.device);
          break;
        }
      }
    });
  }

//function for connecting to the device
  void connectToDevice(BluetoothDevice device) async {
    print("Connecting to device: ${device.name}");
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
    print("Connected to ${device.name}");
  }

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      print('Service found: ${service.uuid}');
      service.characteristics.forEach((characteristic) {
        print('characteristic found: ${characteristic.uuid}');
        if (characteristic.properties.read) {
          setState(() {
            weightCharacteristic = characteristic;
          });
          readWeightData(characteristic);
        }
      });
    });
  }

  void readWeightData(BluetoothCharacteristic characteristic) async {
    var value = await characteristic.read();
    // Convert the byte data into meaningful weight value
    int weightValue = value[0];
    setState(() {
      weight = "$weightValue kg";
    });
    print('Weight: $weight kg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BLE Weight Machine"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(connectedDevice != null
                ? "Connected to ${connectedDevice!.name}"
                : "Scanning for devices..."),
            SizedBox(
              height: 20,
            ),
            Text("Weight: $weight"),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  weightCharacteristic != null
                      ? readWeightData(weightCharacteristic!)
                      : null;
                },
                child: Text("Refresh Weight"),),
          ],
        ),
      ),
    );
  }
}
