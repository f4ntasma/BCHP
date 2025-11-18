# modelo_ahorro_energia_banco.py
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime, timedelta
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.preprocessing import StandardScaler
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import joblib
import warnings
warnings.filterwarnings('ignore')

# =============================================================================
# 1. GENERACIÓN DE DATOS SIMULADOS DE CONSUMO ENERGÉTICO DE UN BANCO
# =============================================================================
def generar_datos_consumo_banco(n_dias=365):
    """
    Genera datos simulados de consumo energético para un banco
    """
    # Fechas
    fechas = [datetime(2023, 1, 1) + timedelta(days=i) for i in range(n_dias)]
    
    datos = []
    
    for fecha in fechas:
        # Factores estacionales
        es_fin_de_semana = 1 if fecha.weekday() >= 5 else 0
        es_verano = 1 if 6 <= fecha.month <= 8 else 0
        es_invierno = 1 if fecha.month <= 2 or fecha.month >= 12 else 0
        hora_pico = 1 if 10 <= fecha.hour <= 15 else 0
        
        # Variables de operación del banco
        clientes_dia = np.random.randint(200, 500)  # Número de clientes
        cajeros_operando = np.random.randint(3, 8)   # Cajeros automáticos en uso
        empleados_presentes = np.random.randint(10, 25)  # Empleados en el banco
        transacciones = np.random.randint(100, 400)  # Transacciones realizadas
        
        # Factores externos
        temperatura = np.random.uniform(5, 35)  # Temperatura exterior
        
        # Consumo energético base (kWh)
        consumo_base = 150  # Consumo base del banco
        
        # Factores que afectan el consumo
        consumo = (consumo_base + 
                  clientes_dia * 0.1 +
                  cajeros_operando * 15 +
                  empleados_presentes * 2.5 +
                  transacciones * 0.05 +
                  temperatura * 0.8 * (1 if es_verano else 1.5 if es_invierno else 1) -
                  es_fin_de_semana * 80)
        
        # Añadir ruido aleatorio
        consumo += np.random.normal(0, 10)
        
        # Asegurar que el consumo no sea negativo
        consumo = max(consumo, 50)
        
        datos.append({
            'fecha': fecha,
            'consumo_kwh': consumo,
            'clientes': clientes_dia,
            'cajeros_operando': cajeros_operando,
            'empleados': empleados_presentes,
            'transacciones': transacciones,
            'temperatura': temperatura,
            'es_fin_de_semana': es_fin_de_semana,
            'es_verano': es_verano,
            'es_invierno': es_invierno,
            'hora_pico': hora_pico,
            'dia_semana': fecha.weekday(),
            'mes': fecha.month
        })
    
    return pd.DataFrame(datos)

# =============================================================================
# 2. MODELO DE APRENDIZAJE AUTOMÁTICO
# =============================================================================
def entrenar_modelo_consumo(df):
    """
    Entrena un modelo para predecir el consumo energético
    """
    # Preparar datos
    X = df.drop(['fecha', 'consumo_kwh'], axis=1)
    y = df['consumo_kwh']
    
    # Dividir datos
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Escalar características
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Entrenar modelo de Random Forest
    print("Entrenando modelo de Random Forest...")
    rf_model = RandomForestRegressor(n_estimators=100, random_state=42)
    rf_model.fit(X_train, y_train)
    
    # Evaluar modelo
    y_pred = rf_model.predict(X_test)
    mae = mean_absolute_error(y_test, y_pred)
    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    r2 = r2_score(y_test, y_pred)
    
    print(f"Random Forest - MAE: {mae:.2f}, RMSE: {rmse:.2f}, R²: {r2:.4f}")
    
    # Entrenar modelo de red neuronal
    print("\nEntrenando modelo de red neuronal...")
    model = keras.Sequential([
        layers.Dense(64, activation='relu', input_shape=(X_train_scaled.shape[1],)),
        layers.Dropout(0.2),
        layers.Dense(32, activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(16, activation='relu'),
        layers.Dense(1)
    ])
    
    model.compile(optimizer='adam', loss='mse', metrics=['mae'])
    
    history = model.fit(
        X_train_scaled, y_train,
        epochs=100,
        batch_size=32,
        validation_split=0.2,
        verbose=0
    )
    
    # Evaluar red neuronal
    nn_loss, nn_mae = model.evaluate(X_test_scaled, y_test, verbose=0)
    print(f"Red Neuronal - MAE: {nn_mae:.2f}, Pérdida: {nn_loss:.2f}")
    
    return rf_model, model, scaler, X.columns.tolist()

# =============================================================================
# 3. ANÁLISIS DE AHORRO ENERGÉTICO
# =============================================================================
def analizar_ahorro_energetico(modelo, df, scaler, columnas):
    """
    Analiza oportunidades de ahorro energético
    """
    # Hacer una copia de los datos para simular escenarios de optimización
    df_optimizado = df.copy()
    
    # Escenario 1: Optimización de cajeros (apagar 1 cajero en horas de baja demanda)
    df_cajeros = df.copy()
    df_cajeros['cajeros_operando'] = df_cajeros['cajeros_operando'] - 1
    df_cajeros['cajeros_operando'] = df_cajeros['cajeros_operando'].clip(lower=2)
    
    # Escenario 2: Optimización de climatización (ajustar temperatura)
    df_clima = df.copy()
    df_clima['temperatura'] = df_clima['temperatura'].apply(
        lambda x: min(x + 2, 28) if x > 22 else max(x - 2, 18)
    )
    
    # Escenario 3: Reducción de empleados en horas de baja demanda
    df_empleados = df.copy()
    df_empleados['empleados'] = df_empleados.apply(
        lambda row: max(row['empleados'] - 3, 5) if row['clientes'] < 250 else row['empleados'],
        axis=1
    )
    
    # Predecir consumo para escenarios optimizados
    X_original = df.drop(['fecha', 'consumo_kwh'], axis=1)
    X_cajeros = df_cajeros.drop(['fecha', 'consumo_kwh'], axis=1)
    X_clima = df_clima.drop(['fecha', 'consumo_kwh'], axis=1)
    X_empleados = df_empleados.drop(['fecha', 'consumo_kwh'], axis=1)
    
    # Escalar datos
    X_original_scaled = scaler.transform(X_original)
    X_cajeros_scaled = scaler.transform(X_cajeros)
    X_clima_scaled = scaler.transform(X_clima)
    X_empleados_scaled = scaler.transform(X_empleados)
    
    # Predecir
    consumo_original = modelo.predict(X_original_scaled).flatten()
    consumo_cajeros = modelo.predict(X_cajeros_scaled).flatten()
    consumo_clima = modelo.predict(X_clima_scaled).flatten()
    consumo_empleados = modelo.predict(X_empleados_scaled).flatten()
    
    # Calcular ahorros
    ahorro_cajeros = consumo_original - consumo_cajeros
    ahorro_clima = consumo_original - consumo_clima
    ahorro_empleados = consumo_original - consumo_empleados
    
    # Calcular ahorro total combinando las mejores estrategias
    mejor_escenario = np.minimum.reduce([consumo_cajeros, consumo_clima, consumo_empleados])
    ahorro_total = consumo_original - mejor_escenario
    
    # Resultados
    resultados = {
        'ahorro_cajeros': np.mean(ahorro_cajeros),
        'ahorro_clima': np.mean(ahorro_clima),
        'ahorro_empleados': np.mean(ahorro_empleados),
        'ahorro_total_potencial': np.mean(ahorro_total),
        'porcentaje_ahorro': np.mean(ahorro_total) / np.mean(consumo_original) * 100
    }
    
    return resultados

# =============================================================================
# 4. VISUALIZACIÓN DE RESULTADOS
# =============================================================================
def visualizar_resultados(df, resultados):
    """
    Crea visualizaciones para los resultados del análisis
    """
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    
    # Consumo por día de la semana
    df['dia_semana_nombre'] = df['fecha'].dt.day_name()
    consumo_por_dia = df.groupby('dia_semana_nombre')['consumo_kwh'].mean()
    dias_orden = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    consumo_por_dia = consumo_por_dia.reindex(dias_orden)
    
    axes[0, 0].bar(consumo_por_dia.index, consumo_por_dia.values)
    axes[0, 0].set_title('Consumo Energético Promedio por Día de la Semana')
    axes[0, 0].tick_params(axis='x', rotation=45)
    
    # Consumo por mes
    df['mes_nombre'] = df['fecha'].dt.month_name()
    consumo_por_mes = df.groupby('mes_nombre')['consumo_kwh'].mean()
    meses_orden = ['January', 'February', 'March', 'April', 'May', 'June', 
                  'July', 'August', 'September', 'October', 'November', 'December']
    consumo_por_mes = consumo_por_mes.reindex(meses_orden)
    
    axes[0, 1].bar(consumo_por_mes.index, consumo_por_mes.values)
    axes[0, 1].set_title('Consumo Energético Promedio por Mes')
    axes[0, 1].tick_params(axis='x', rotation=45)
    
    # Correlación entre variables
    corr_matrix = df[['consumo_kwh', 'clientes', 'cajeros_operando', 
                      'empleados', 'transacciones', 'temperatura']].corr()
    sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', center=0, ax=axes[1, 0])
    axes[1, 0].set_title('Matriz de Correlación')
    
    # Potencial de ahorro por estrategia
    estrategias = ['Optimización Cajeros', 'Optimización Clima', 'Optimización Área Personal', 'Ahorro Total']
    ahorros = [resultados['ahorro_cajeros'], resultados['ahorro_clima'], 
               resultados['ahorro_empleados'], resultados['ahorro_total_potencial']]
    
    axes[1, 1].bar(estrategias, ahorros, color=['blue', 'green', 'red', 'purple'])
    axes[1, 1].set_title('Potencial de Ahorro Energético por Estrategia')
    axes[1, 1].set_ylabel('Ahorro Promedio (kWh)')
    axes[1, 1].tick_params(axis='x', rotation=45)
    
    plt.tight_layout()
    plt.savefig('analisis_ahorro_energetico.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    # Mostrar resultados numéricos
    print("\n" + "="*50)
    print("ANÁLISIS DE AHORRO ENERGÉTICO - RESULTADOS")
    print("="*50)
    print(f"Consumo energético promedio: {df['consumo_kwh'].mean():.2f} kWh")
    print(f"Potencial de ahorro con optimización de cajeros: {resultados['ahorro_cajeros']:.2f} kWh ({resultados['ahorro_cajeros']/df['consumo_kwh'].mean()*100:.1f}%)")
    print(f"Potencial de ahorro con optimización de climatización: {resultados['ahorro_clima']:.2f} kWh ({resultados['ahorro_clima']/df['consumo_kwh'].mean()*100:.1f}%)")
    print(f"Potencial de ahorro con optimización de personal: {resultados['ahorro_empleados']:.2f} kWh ({resultados['ahorro_empleados']/df['consumo_kwh'].mean()*100:.1f}%)")
    print(f"Potencial de ahorro total combinando estrategias: {resultados['ahorro_total_potencial']:.2f} kWh ({resultados['porcentaje_ahorro']:.1f}%)")
    
    # Recomendaciones específicas
    print("\n" + "="*50)
    print("RECOMENDACIONES ESPECÍFICAS")
    print("="*50)
    if resultados['ahorro_cajeros'] > 5:
        print("✓ Apague 1-2 cajeros automáticos durante horas de baja demanda")
    if resultados['ahorro_clima'] > 8:
        print("✓ Ajuste la temperatura del termostato en 2°C (calefacción en invierno, aire acondicionado en verano)")
    if resultados['ahorro_empleados'] > 6:
        print("✓ Optimice el horario del personal según la demanda de clientes")
    
    print("✓ Implemente un sistema de monitorización energética en tiempo real")
    print("✓ Considere la instalación de paneles solares para autoconsumo")
    print("✓ Actualice a equipos y iluminación de alta eficiencia energética")

# =============================================================================
# 5. EJECUCIÓN PRINCIPAL
# =============================================================================
if __name__ == "__main__":
    # Generar datos de consumo
    print("Generando datos de consumo energético del banco...")
    df_consumo = generar_datos_consumo_banco(365)
    
    # Entrenar modelo
    print("Entrenando modelos de predicción de consumo...")
    rf_model, nn_model, scaler, columnas = entrenar_modelo_consumo(df_consumo)
    
    # Analizar oportunidades de ahorro
    print("\nAnalizando oportunidades de ahorro energético...")
    resultados_ahorro = analizar_ahorro_energetico(nn_model, df_consumo, scaler, columnas)
    
    # Visualizar resultados
    visualizar_resultados(df_consumo, resultados_ahorro)
    
    # Guardar modelo para uso futuro
    joblib.dump(rf_model, 'modelo_ahorro_energetico_rf.pkl')
    nn_model.save('modelo_ahorro_energetico_nn.h5')
    joblib.dump(scaler, 'escalador_ahorro_energetico.pkl')
    
    print("\nModelos guardados para uso futuro:")
    print("- modelo_ahorro_energetico_rf.pkl (Random Forest)")
    print("- modelo_ahorro_energetico_nn.h5 (Red Neuronal)")
    print("- escalador_ahorro_energetico.pkl (Escalador de características)")