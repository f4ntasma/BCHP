import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnergyScreen extends StatelessWidget {
  const EnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        title: Text(
          "Consumo de Energía",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Gráfico mensual de consumo",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Text("Aquí irá el gráfico de consumo"),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Este mes ahorraste un 12% en comparación al anterior.",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}