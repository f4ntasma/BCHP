import joblib
import warnings
warnings.filterwarnings('ignore')

print("Cargando escalador y columnas...")

try:
    # Cargar el escalador
    scaler = joblib.load('escalador_ahorro_energetico.pkl')
    
    # Cargar el modelo RF solo para obtener las columnas (si el script original no las guardó)
    # Si 'columnas' no está guardado, necesitaremos el df_consumo.
    # Por ahora, asumamos que las columnas son las del script:
    columnas = [
        'clientes', 'cajeros_operando', 'empleados', 'transacciones', 
        'temperatura', 'es_fin_de_semana', 'es_verano', 'es_invierno', 
        'hora_pico', 'dia_semana', 'mes'
    ]
    
    # ¡ESTO ES LO IMPORTANTE!
    print("\n--- ¡COPIA Y PEGA ESTO EN TU CÓDIGO DE DART! ---")
    
    print("\n// Orden exacto de las columnas:")
    print(f"final List<String> featureOrder = {columnas};")
    
    print("\n// Valores de Media (mean_):")
    print(f"final List<double> meanValues = {scaler.mean_.tolist()};")
    
    print("\n// Valores de Escala (scale_ o std_dev):")
    print(f"final List<double> scaleValues = {scaler.scale_.tolist()};")
    
    print("\n--- FIN DE LOS DATOS PARA DART ---")

except FileNotFoundError:
    print("Error: No se encontró 'escalador_ahorro_energetico.pkl'.")
    print("Asegúrate de ejecutar primero tu script 'modelo_ahorro_energia_banco.py'.")
except Exception as e:
    print(f"Ocurrió un error: {e}")