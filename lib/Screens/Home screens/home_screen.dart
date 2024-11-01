import 'package:bluetooth_connect/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];

  void startScan() {
    devicesList.clear();
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devicesList.contains(r.device)) {
          setState(() {
            devicesList.add(r.device);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        centerTitle: true,
        title: Text("Bluetooth Devices")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: startScan,
              child: Text("Scan"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: devicesList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                    
                      tileColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                      ),
                      title: Text(devicesList[index].name.isEmpty ? 'Unknown Device' : devicesList[index].name),
                      subtitle: Text(devicesList[index].id.toString()),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}