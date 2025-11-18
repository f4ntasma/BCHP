import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  bool isLoading = true;           // carga inicial
  bool _isDiscovering = false;     // en proceso
  String? _connectingAddr;         // spinner por ítem al conectar
  StreamSubscription<BluetoothDiscoveryResult>? _discoverySub;

  @override
  void initState() {
    super.initState();
    // Escucha cambios en el estado del Bluetooth (encendido/apagado)
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    _loadLastDevice();
    _getBondedDevices();
  }

  @override
  void dispose() {
    _discoverySub?.cancel();
    super.dispose();
  }

  // --- NUEVO: Helper para solicitar permisos ---
  Future<bool> _requestPermissions() async {
    // Cuando pides varios permisos, obtienes un mapa de resultados.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    // Verificamos que AMBOS permisos hayan sido concedidos.
    return statuses[Permission.bluetoothScan]!.isGranted && statuses[Permission.bluetoothConnect]!.isGranted;
  }

  Future<void> _getBondedDevices() async {
    setState(() => isLoading = true);
    try {
      final bondedDevices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        devicesList = bondedDevices;
      });
    } catch (e) {
      debugPrint("Error obteniendo dispositivos: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error obteniendo emparejados: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Buscar dispositivos cercanos (sin abrir conexión SPP)
  Future<void> _toggleDiscovery() async {
    if (_isDiscovering) {
      await _discoverySub?.cancel();
      setState(() => _isDiscovering = false);
      return;
    }

    // --- NUEVO: Verificación de estado y permisos ---
    // 1. Comprueba si el Bluetooth está encendido
    final btState = await FlutterBluetoothSerial.instance.state;
    if (btState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      return; // Espera a que el usuario lo active, el listener de estado actualizará la UI
    }

    // 2. Comprueba si tenemos permisos
    if (!await _requestPermissions()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Se requieren permisos de Bluetooth para buscar dispositivos.')));
      return;
    }
    setState(() => _isDiscovering = true);
    // mantenemos los emparejados y vamos agregando nuevos si aparecen
    _discoverySub =
        FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      final d = result.device;
      final exists = devicesList.any((x) => x.address == d.address);
      if (!exists) {
        setState(() => devicesList.add(d));
      } else {
        // actualiza nombre si llega diferente
        final i = devicesList.indexWhere((x) => x.address == d.address);
        if (i != -1 && (devicesList[i].name ?? '') != (d.name ?? '')) {
          setState(() => devicesList[i] = d);
        }
      }
    }, onError: (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error buscando: $e')));
    }, onDone: () {
      setState(() => _isDiscovering = false);
    });
  }

  Future<void> _loadLastDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAddress = prefs.getString("last_device_address");
    if (lastAddress == null) return;

    try {
      final bondedDevices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      final matching =
          bondedDevices.where((d) => d.address == lastAddress).toList();
      if (matching.isNotEmpty) {
        setState(() => connectedDevice = matching.first);
      }
    } catch (e) {
      debugPrint("No se pudo cargar último dispositivo: $e");
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device,
      {bool auto = false}) async {
    // solo mostramos spinner y “guardamos” como conectado (tal como hacías),
    // sin abrir socket SPP
    setState(() => _connectingAddr = device.address);
    // detén búsqueda para evitar estados raros
    if (_isDiscovering) {
      await _discoverySub?.cancel();
      setState(() => _isDiscovering = false);
    }

    try {
      await FlutterBluetoothSerial.instance
          .bondDeviceAtAddress(device.address); // emparejar si falta
      setState(() => connectedDevice = device);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("last_device_address", device.address);
      await prefs.setString(
          "last_device_name", device.name ?? "Desconocido");

      if (!auto) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conectado a ${device.name ?? device.address}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar: $e')),
      );
    } finally {
      setState(() => _connectingAddr = null);
    }
  }

  Future<void> _disconnect() async {
    setState(() => connectedDevice = null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("last_device_address");
    await prefs.remove("last_device_name");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dispositivo desconectado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = devicesList;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        title: Text("Conexión Bluetooth",
            style: GoogleFonts.poppins(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Wrap evita overflow amarillo y se ve mejor en pantallas angostas
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: isLoading || _bluetoothState != BluetoothState.STATE_ON
                      ? null
                      : (_isDiscovering ? null : _toggleDiscovery),
                  icon: _isDiscovering
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search),
                  label: Text(_bluetoothState == BluetoothState.STATE_ON ? (_isDiscovering ? "Buscando..." : "Buscar") : "Bluetooth apagado"),
                ),
                OutlinedButton.icon(
                  onPressed: isLoading ? null : _getBondedDevices,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Emparejados"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isDiscovering) const LinearProgressIndicator(minHeight: 3),

            const SizedBox(height: 12),

            if (connectedDevice != null)
              Card(
                color: Colors.green.shade100,
                child: ListTile(
                  leading: const Icon(Icons.bluetooth_connected,
                      color: Colors.green),
                  title:
                      Text(connectedDevice!.name ?? "Dispositivo conectado"),
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : list.isEmpty
                      ? Center(
                          child: Text("No se encontraron dispositivos",
                              style: GoogleFonts.poppins()))
                      : ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final device = list[index];
                            final isConnected =
                                connectedDevice?.address == device.address;
                            final isConnecting =
                                _connectingAddr == device.address;

                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                leading: Icon(
                                  isConnected
                                      ? Icons.bluetooth_connected
                                      : Icons.bluetooth,
                                  color: isConnected
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                                title: Text(
                                    device.name ?? "Dispositivo desconocido"),
                                subtitle: Text(device.address),
                                trailing: SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: isConnected || isConnecting
                                        ? null
                                        : () => _connectToDevice(device),
                                    child: isConnecting
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : Text(isConnected
                                            ? "Conectado"
                                            : "Conectar"),
                                  ),
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