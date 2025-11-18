import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class PredictionService {
  Interpreter? _interpreter;
  // Valores de Media (mean_):
  final List<double> meanValues = const [
    353.6849315068493,
    4.859589041095891,
    17.13013698630137,
    259.9931506849315,
    20.580034453131766,
    0.2910958904109589,
    0.2636986301369863,
    0.2191780821917808,
    0.0, // <-- Hora Pico xD
    3.0445205479452055,
    6.578767123287672
  ];

  // Valores de Escala (scale_ o std_dev):
  final List<double> scaleValues = const [
    88.92641666658841,
    1.381436554605549,
    4.349088549812646,
    80.48325756085816,
    8.63527492157366,
    0.45426762265960574,
    0.44063779070894854,
    0.4136895580970274,
    1.0, // <-- Corresponde a hora_pico xD
    2.0089024749069755,
    3.354198124046562
  ];
  // --- FIN DE LOS VALORES ---

  // Carga el modelo .tflite desde los assets
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/modelo_ahorro.tflite');
      debugPrint("Modelo TFLite cargado exitosamente.");
    } catch (e) {
      debugPrint("Error al cargar el modelo TFLite: $e");
    }
  }

  // Función para predecir el consumo
  double predictConsumption({
    required double clientes,
    required double cajerosOperando,
    required double empleados,
    required double transacciones,
    required double temperatura,
    required double esFinDeSemana, // 1.0 o 0.0
    required double esVerano, // 1.0 o 0.0
    required double esInvierno, // 1.0 o 0.0
    required double horaPico, // 1.0 o 0.0
    required double diaSemana, // 0-6
    required double mes, // 1-12
  }) {
    if (_interpreter == null) {
      debugPrint("Error: El intérprete del modelo no está cargado.");
      return 0.0;
    }

    // 1. Crear el array de entrada en el orden correcto
    // (El orden viene de tu script: 'clientes', 'cajeros_operando', 'empleados', ...)
    List<double> rawInput = [
      clientes,
      cajerosOperando,
      empleados,
      transacciones,
      temperatura,
      esFinDeSemana,
      esVerano,
      esInvierno,
      horaPico, // <-- Importante, ver advertencia
      diaSemana,
      mes
    ];

    // 2. Escalar los datos manualmente
    List<double> scaledInput = [];
    for (int i = 0; i < rawInput.length; i++) {
      // Fórmula: z = (x - mean) / scale
      double scaledValue = (rawInput[i] - meanValues[i]) / scaleValues[i];
      scaledInput.add(scaledValue);
    }

    // 3. Preparar la entrada y salida para el modelo
    var inputTensor = [scaledInput]; // Forma [1, 11]
    var outputTensor = List.filled(1 * 1, 0.0).reshape([1, 1]); // Forma [1, 1]

    // 4. Ejecutar la predicción
    try {
      _interpreter!.run(inputTensor, outputTensor);
    } catch (e) {
      debugPrint("Error al ejecutar la inferencia: $e");
      return 0.0;
    }

    // 5. Devolver el resultado
    return outputTensor[0][0];
  }

  // No olvides liberar los recursos cuando ya no uses el servicio
  void dispose() {
    _interpreter?.close();
  }
}