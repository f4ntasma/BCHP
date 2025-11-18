import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
// 1. IMPORTA TU SERVICIO
import 'package:smart_home_bcp/services/prediction_service.dart';

// 2. CONVIERTE A STATEFULWIDGET
class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  // 3. AÑADE LA LÓGICA DEL MODELO Y ESTADO
  final PredictionService _predictionService = PredictionService();
  bool _isLoading = true;
  double _predictedConsumption = 0.0;
  double _savings = 0.0; // <-- Nuevo estado para el ahorro
  String _loadingMessage = "Cargando modelo de IA...";

  // Datos simulados que muestran una reducción de consumo gracias a la IA
  final List<double> _monthlyConsumption = [
    580.0, 565.5, 540.2, 510.8, 490.1, 475.9, // Ene-Jun: Consumo inicial alto
    460.4, 455.0, 452.3, 0, 0, 0 // Jul-Sep: Se estabiliza. Oct-Dic se llenarán.
  ];

  @override
  void initState() {
    super.initState();
    // 4. CARGA EL MODELO Y EJECUTA LA PREDICCIÓN AL INICIAR
    _loadModelAndPredict();
  }

  @override
  void dispose() {
    // 5. LIBERA RECURSOS AL CERRAR LA PANTALLA
    _predictionService.dispose();
    super.dispose();
  }

  Future<void> _loadModelAndPredict() async {
    // Carga el modelo
    await _predictionService.loadModel();

    // Simula los datos (ya que no hay Arduino)
    final simulacion = {
      'clientes': 300.0,
      'cajerosOperando': 5.0,
      'empleados': 18.0,
      'transacciones': 250.0,
      'temperatura': 24.5,
      'esFinDeSemana': 0.0,
      'esVerano': 0.0,
      'esInvierno': 1.0, 
      'horaPico': 0.0, 
      'diaSemana': 2.0,
      'mes': 10.0,
    };

    double prediction = _predictionService.predictConsumption(
      clientes: simulacion['clientes']!,
      cajerosOperando: simulacion['cajerosOperando']!,
      empleados: simulacion['empleados']!,
      transacciones: simulacion['transacciones']!,
      temperatura: simulacion['temperatura']!,
      esFinDeSemana: simulacion['esFinDeSemana']!,
      esVerano: simulacion['esVerano']!,
      esInvierno: simulacion['esInvierno']!,
      horaPico: simulacion['horaPico']!,
      diaSemana: simulacion['diaSemana']!,
      mes: simulacion['mes']!,
    );

    // 7. Actualiza la UI con el resultado
    if (mounted) { 
      setState(() {
        final previousMonthConsumption = _monthlyConsumption[8];
        if (previousMonthConsumption > 0) {
          _savings = previousMonthConsumption - prediction;
        }

        _predictedConsumption = prediction;
        _monthlyConsumption[9] = prediction;
        _isLoading = false;
        _loadingMessage = "Predicción lista";
      });
    }
  }

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
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _loadingMessage,
                    style: GoogleFonts.poppins(), 
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView( 
                children: [
                  Text(
                    "Gráfico mensual de consumo",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: _buildMonthlyChart(),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    "Predicción de Consumo (Simulado):",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    // Muestra el valor de la predicción
                    "${_predictedConsumption.toStringAsFixed(2)} kWh",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- NUEVA TARJETA DE AHORRO ---
                  Card(
                    elevation: 0,
                    color: Colors.green.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.green.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.savings_rounded, color: Colors.green.shade800, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "AHORRO ESTIMADO",
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green.shade900, letterSpacing: 0.5),
                                ),
                                Text(
                                  "${_savings.toStringAsFixed(1)} kWh",
                                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                                ),
                                Text("Respecto al mes anterior", style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  // Widget que construye el gráfico de barras
  Widget _buildMonthlyChart() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;

    return BarChart(
      BarChartData(
        // Estilos y configuración del gráfico
        alignment: BarChartAlignment.spaceAround,
        maxY: 600, // Límite superior del eje Y (ajusta según tus datos)
        barTouchData: BarTouchData(
          // Tooltips al tocar una barra
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final month = _getMonthAbbr(group.x.toInt());
              return BarTooltipItem(
                '$month\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '${rod.toY.toStringAsFixed(1)} kWh',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          // Títulos de los ejes X e Y
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles:false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
              if (value == 0 || value == 300 || value == 600) {
                return Text('${value.toInt()}', style: TextStyle(color: textColor, fontSize: 10));
              }
              return const Text('');
            })
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              return SideTitleWidget(axisSide: meta.axisSide, child: Text(_getMonthAbbr(value.toInt()), style: TextStyle(color: textColor, fontSize: 10)));
            }),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        // Datos de las barras
        barGroups: List.generate(12, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _monthlyConsumption[i],
                // El mes actual (predicción) usa el color primario.
                // Los meses pasados usan una versión más clara del primario.
                color: i == 9 ? primaryColor : primaryColor.withOpacity(0.4),
                width: 12,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Helper para obtener la abreviatura del mes
  String _getMonthAbbr(int monthIndex) {
    return ['E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'][monthIndex];
  }
}