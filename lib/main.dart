import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utils/app_theme.dart';
import 'utils/transitions.dart'; // fadeThrough(page)

// Providers
import 'services/theme_provider.dart';
import 'services/lights_provider.dart';
import 'services/fan_provider.dart';

// Pantallas
import 'screens/home_screen.dart';
import 'screens/bluetooth_screen.dart';
import 'screens/energy_screen.dart';
import 'screens/light_control.dart';
import 'screens/fan_control.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LightsProvider()),
        ChangeNotifierProvider(create: (_) => FanProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, theme, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Home',
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          themeMode: theme.themeMode, // o: theme.isDark ? ThemeMode.dark : ThemeMode.light
          onGenerateRoute: _onGenerateRoute,
          initialRoute: '/', // 👈 sin splash
        ),
      ),
    );
  }
}

Route<dynamic> _onGenerateRoute(RouteSettings s) {
  switch (s.name) {
    case '/':
      return fadeThrough(const HomeScreen());
    case '/bluetooth':
      return fadeThrough(const BluetoothScreen());
    case '/energy':
      return fadeThrough(const EnergyScreen());
    case '/lights':
      return fadeThrough(const LightControlScreen());
    case '/fan':
      return fadeThrough(const FanControlScreen());
    default:
      return fadeThrough(const HomeScreen());
  }
}