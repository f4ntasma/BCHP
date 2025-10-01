import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLastDevice();
    _getBondedDevices();
  }

  Future<void> _getBondedDevices() async {
    List<BluetoothDevice> bondedDevices = [];
    try {
      bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      print("Error obteniendo dispositivos: $e");
    }
    setState(() {
      devicesList = bondedDevices;
      isLoading = false;
    });
  }

  Future<void> _loadLastDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAddress = prefs.getString("last_device_address");
    if (lastAddress != null) {
      try {
        final bondedDevices =
            await FlutterBluetoothSerial.instance.getBondedDevices();

        final matching =
            bondedDevices.where((d) => d.address == lastAddress).toList();

        if (matching.isNotEmpty) {
          _connectToDevice(matching.first, auto: true);
        }
      } catch (e) {
        print("No se pudo reconectar: $e");
      }
    }
  }

  void _connectToDevice(BluetoothDevice device, {bool auto = false}) async {
    try {
      await FlutterBluetoothSerial.instance.bondDeviceAtAddress(device.address);
      setState(() {
        connectedDevice = device;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("last_device_address", device.address);
      await prefs.setString("last_device_name", device.name ?? "Desconocido");

      if (!auto) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conectado a ${device.name}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar: $e')),
      );
    }
  }

  void _disconnect() async {
    setState(() {
      connectedDevice = null;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("last_device_address");
    await prefs.remove("last_device_name");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dispositivo desconectado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        title: Text(
          "Conexión Bluetooth",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _getBondedDevices,
                    icon: const Icon(Icons.search),
                    label: const Text("Buscar dispositivos"),
                  ),
                  const SizedBox(height: 20),
                  if (connectedDevice != null)
                    Card(
                      color: Colors.green.shade100,
                      child: ListTile(
                        leading: const Icon(Icons.bluetooth_connected,
                            color: Colors.green),
                        title: Text(connectedDevice!.name ??
                            "Dispositivo conectado"),
                        subtitle: Text(connectedDevice!.address),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: _disconnect,
                          child: const Text("Desconectar"),
                        ),
                      ),
                    ),
                  Expanded(
                    child: devicesList.isEmpty
                        ? Center(
                            child: Text("No se encontraron dispositivos",
                                style: GoogleFonts.poppins()))
                        : ListView.builder(
                            itemCount: devicesList.length,
                            itemBuilder: (context, index) {
                              final device = devicesList[index];
                              final isConnected = connectedDevice?.address ==
                                  device.address;
                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  leading: const Icon(Icons.bluetooth,
                                      color: Colors.blue),
                                  title: Text(
                                      device.name ?? "Dispositivo desconocido"),
                                  subtitle: Text(device.address),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isConnected
                                          ? Colors.green
                                          : Colors.blue,
                                    ),
                                    onPressed: () =>
                                        _connectToDevice(device),
                                    child: Text(isConnected
                                        ? "Conectado"
                                        : "Conectar"),
                                  ),
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