import tensorflow as tf
import os

# --- Configuración ---
H5_MODEL_FILE = 'modelo_ahorro_energetico_nn.h5'
TFLITE_MODEL_FILE = 'modelo_ahorro.tflite'
# -------------------

if not os.path.exists(H5_MODEL_FILE):
    print(f"Error: No se encontró el archivo '{H5_MODEL_FILE}'")
else:
    try:
        # Cargar el modelo Keras .h5
        # 
        # === ESTA ES LA LÍNEA CORREGIDA ===
        model = tf.keras.models.load_model(H5_MODEL_FILE, compile=False)
        # ================================
        
        # Crear el convertidor
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        
        # Convertir el modelo
        tflite_model = converter.convert()
        
        # Guardar el modelo .tflite
        with open(TFLITE_MODEL_FILE, 'wb') as f:
            f.write(tflite_model)
            
        print(f"¡Éxito! Modelo convertido y guardado como '{TFLITE_MODEL_FILE}'")
        
    except Exception as e:
        print(f"Ocurrió un error during la conversión: {e}")