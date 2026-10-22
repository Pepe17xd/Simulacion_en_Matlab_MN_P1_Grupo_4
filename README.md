# Proyecto 2 — Modelación térmica con métodos numéricos

## ¿Qué hace este proyecto?

Simula la distribución estacionaria de temperatura en una placa electrónica idealizada. Usa diferencias finitas para discretizar el modelo y compara Gauss-Seidel y Gradiente Conjugado con una solución directa de referencia.

## ¿Qué necesito?

- MATLAB R2025a. La ejecución de referencia se comprobó con MATLAB R2025a Update 1 en Windows.
- No se requieren toolboxes adicionales.
- Una computadora con memoria suficiente para trabajar con la malla más fina. La ejecución completa tarda varios minutos y el tiempo depende del equipo.

No se ha verificado compatibilidad con otras versiones de MATLAB ni con otros sistemas operativos.

## ¿Cómo descargarlo?

1. Abre https://github.com/Pepe17xd/Simulacion_en_Matlab_MN_P1_Grupo_4 en tu navegador.
2. Haz clic en el botón verde **Code**.
3. Selecciona **Download ZIP**.
4. Espera a que termine la descarga.
5. Busca el archivo ZIP en la carpeta **Descargas**.
6. Haz clic derecho sobre el ZIP y elige **Extraer todo**.
7. Abre la carpeta extraída.

No necesitas instalar Git ni usar la terminal.

## ¿Cómo ejecutarlo?

1. Abre MATLAB.
2. En MATLAB, entra a la carpeta que extrajiste.
3. Abre `MN_Grupo4_Proyecto_P2_Unificado.mlx`.
4. Espera a que se abra MATLAB Live Editor.
5. Haz clic en **Run All** o **Ejecutar todo**.
6. Espera a que terminen los experimentos.
7. Revisa las figuras, tablas y resultados que muestra el documento.

Los archivos generados se guardan junto al Live Script, en `resultados/run_.../`. Cada ejecución crea una carpeta nueva para conservar las corridas anteriores. Allí se guardan tablas CSV, metadatos JSON, datos MAT y figuras PDF. Los tiempos pueden variar según la computadora.

## Experimentos

- **A — Caso base:** compara los métodos numéricos y su convergencia.
- **B — Refinamiento espacial:** compara cuatro resoluciones de malla.
- **C — Sensibilidad térmica:** varía por separado las potencias de CPU y GPU.
- **D — Validación y estrés numérico:** comprueba propiedades del sistema y prueba casos exigentes.
