# Smart Home BCP

Aplicación móvil en Flutter para monitorizar y controlar funciones básicas de un hogar (o espacio corporativo) con identidad BCP. Integra control por Bluetooth, simulación de luces y ventilación, estimación de consumo energético con IA y soporte de temas claro/oscuro.

## Funcionalidades
- Panel principal con accesos a Bluetooth, luces, ventilación y módulo de energía, con transiciones animadas y mascota en pantalla.
- Bluetooth: escaneo y emparejamiento de dispositivos, reconexión al último equipo recordado y manejo de permisos nativos.
- Energía: gráfico mensual (fl_chart) y predicción de consumo usando un modelo TensorFlow Lite (`assets/modelo_ahorro.tflite`), incluyendo cálculo de ahorro estimado.
- Luces y ventilación: control simulado mediante `LightsProvider` y `FanProvider` para encendido/apagado y estado actual.
- Temas claro/oscuro: gestión centralizada con `ThemeProvider` y tipografías de Google Fonts.

## Stack tecnológico
- Flutter 3.x y Dart
- Provider para gestión de estado
- `flutter_bluetooth_serial_plus`, `permission_handler` para conectividad
- `tflite_flutter` para inferencia local del modelo de energía
- `fl_chart` para visualización

## Requisitos previos
- Flutter y Dart instalados
- Dispositivo o emulador Android con Bluetooth habilitado
- SDKs y dependencias de Android/iOS configuradas

## Puesta en marcha
1) Instala dependencias: `flutter pub get`
2) Ejecuta la app: `flutter run`
3) (Opcional) Pruebas unitarias: `flutter test`

## Estructura relevante
- `lib/main.dart`: enrutamiento y configuración de temas
- `lib/screens/home_screen.dart`: panel principal
- `lib/screens/bluetooth_screen.dart`: flujo de descubrimiento y conexión
- `lib/screens/energy_screen.dart`: gráfico y predicción de consumo
- `lib/services/prediction_service.dart`: carga del modelo TFLite y lógica de inferencia
- `assets/`: recursos gráficos y modelo de IA

## Modelo de IA
El modelo `modelo_ahorro.tflite` se carga localmente para estimar consumo y ahorro esperado. Asegúrate de mantener el archivo en `assets/` y de declararlo en `pubspec.yaml`.