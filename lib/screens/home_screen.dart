import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/theme_provider.dart';
import '../widgets/mascot_foreground.dart'; // 👈 mascota en primer plano

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[100]
          : Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF003366),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/Logo-bcp-vector.png',
                  height: 44,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF003366)),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF003366),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/Logo-bcp-vector.png',
                      height: 76,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Inicio"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bolt),
              title: const Text("Consumo de Energía"),
              onTap: () => Navigator.pushNamed(context, '/energy'),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text("Cambiar Tema"),
              onTap: themeProvider.toggleTheme,
            ),
          ],
        ),
      ),

      // 👇 Grid de funciones + mascota en primer plano (no bloquea taps)
      body: Stack(
        children: [
          // 1. El fondo, que se dibuja primero (detrás de todo).
          const MascotBackground(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.05,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.bluetooth,
                  title: "Bluetooth",
                  color: Colors.blueAccent,
                  onTap: () => Navigator.pushNamed(context, '/bluetooth'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.lightbulb,
                  title: "Luces",
                  color: Colors.amber,
                  onTap: () => Navigator.pushNamed(context, '/lights'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.air,
                  title: "Ventilación",
                  color: Colors.teal,
                  onTap: () => Navigator.pushNamed(context, '/fan'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.bolt,
                  title: "Energía",
                  color: Colors.redAccent,
                  onTap: () => Navigator.pushNamed(context, '/energy'),
                ),
              ],
            ),
          ),

          // Mascota completa + burbuja aleatoria (1 por apertura)
          const MascotForeground(),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
