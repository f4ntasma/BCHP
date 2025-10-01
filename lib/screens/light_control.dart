import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/lights_provider.dart';
import '../widgets/control_center_slider_horizontal.dart';

class LightControlScreen extends StatelessWidget {
  const LightControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lights = context.watch<LightsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        title: Text("Control de Luces",
            style: GoogleFonts.poppins(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Brillo: ${lights.brightness.toInt()}%",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            ControlCenterSliderHorizontal(
              value: lights.brightness / 100,
              onChanged: (val) => lights.setBrightness(val * 100),
              icon: Icons.lightbulb,
              gradient: const LinearGradient(
                colors: [Colors.black54, Colors.yellow],
              ),
            ),
            const SizedBox(height: 20),
            Text("Calidez: ${lights.warmth.toInt()}K",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            ControlCenterSliderHorizontal(
              value: (lights.warmth - 2700.0) / (6500.0 - 2700.0),
              onChanged: (val) =>
                  lights.setWarmth(2700.0 + val * (6500.0 - 2700.0)),
              icon: Icons.wb_sunny,
              gradient: const LinearGradient(
                colors: [Colors.white, Colors.orange],
              ),
            ),
            const SizedBox(height: 30),
            Text("Luces por habitación",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 16)),
            Expanded(
              child: ListView(
                children: lights.rooms.keys.map((room) {
                  return SwitchListTile(
                    title: Text(room, style: GoogleFonts.poppins()),
                    value: lights.rooms[room]!,
                    onChanged: (val) => lights.toggleRoom(room, val),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                String newRoom = "";
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Agregar nueva sala"),
                    content: TextField(
                      onChanged: (v) => newRoom = v,
                      decoration:
                          const InputDecoration(hintText: "Ej: Oficina"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (newRoom.isNotEmpty) {
                            context.read<LightsProvider>().addRoom(newRoom);
                          }
                          Navigator.pop(context);
                        },
                        child: const Text("Agregar"),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Agregar sala"),
            ),
          ],
        ),
      ),
    );
  }
}