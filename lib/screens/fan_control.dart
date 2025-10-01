import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/fan_provider.dart';
import '../widgets/control_center_slider_horizontal.dart';

class FanControlScreen extends StatelessWidget {
  const FanControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fan = context.watch<FanProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        title: Text("Control de Ventilación",
            style: GoogleFonts.poppins(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              title: Text("Ventilación",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              value: fan.fanOn,
              onChanged: fan.toggleFan,
            ),
            const SizedBox(height: 20),
            Text("Velocidad: ${fan.speed.toInt()}%",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            ControlCenterSliderHorizontal(
              value: fan.speed / 100,
              onChanged: (val) => fan.setSpeed(val * 100),
              icon: Icons.air,
              gradient: const LinearGradient(
                colors: [Colors.grey, Colors.teal],
              ),
            ),
            const SizedBox(height: 20),
            Text("Objetivo: ${fan.targetTemp.toStringAsFixed(1)}°C",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            ControlCenterSliderHorizontal(
              value: (fan.targetTemp - 18.0) / (30.0 - 18.0),
              onChanged: (val) => fan.setTargetTemp(18.0 + val * 12.0),
              icon: Icons.thermostat,
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.orange, Colors.redAccent],
              ),
            ),
            const SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              color: fan.getTempColor(fan.currentTemp),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    "Temperatura actual: ${fan.currentTemp.toStringAsFixed(1)}°C",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}