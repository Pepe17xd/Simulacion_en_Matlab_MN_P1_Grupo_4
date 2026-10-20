# Simulación MATLAB

## Ejecución desde ZIP

1. Extraiga el ZIP del proyecto conservando la carpeta `simulacion/` en la raíz. Si el paquete también contiene `Latex/`, puede dejarla al mismo nivel.
2. Abra MATLAB y navegue a la carpeta extraída. No hace falta Git, Python, paquetes de terceros ni datos precargados.
3. Abra y ejecute `simulacion/00_Proyecto_Principal.mlx` o, para el punto de entrada `.m`, desde la raíz del proyecto ejecute:

   ```matlab
   codigo=char(strjoin(readlines(fullfile(pwd,'simulacion','00_Proyecto_Principal.m'),'Encoding','UTF-8'),newline)); eval(codigo)
   ```

   MATLAB da prioridad al `.mlx` al intentar `run` con este nombre base; `readlines` con UTF-8 y `eval` ejecutan el `.m` explícitamente y conservan sus comentarios codificados. El script localiza dinámicamente su carpeta. Si MATLAB se inició desde otra ubicación, navegue a la raíz extraída o abra el Live Script desde el explorador de archivos.

## Modos

Ambos puntos de entrada definen `modo_completo=false` para el caso base rápido. Para regenerar experimentos A–D desde `.mlx` o `.m`, cambie esa asignación a `true` en el archivo que vaya a ejecutar, o invoque directamente:

```matlab
addpath(fullfile(pwd,'simulacion'))
r = ejecutar_proyecto(true);
```

El modo completo calcula nuevamente las exportaciones CSV, MAT, JSON y figuras desde los parámetros y las funciones fuente; no usa resultados previos como entradas. Los tiempos llevan una corrida de calentamiento y tres repeticiones por configuración por defecto. El campo, residuos, potencias y errores deben reproducirse dentro del redondeo numérico; los tiempos dependen del hardware y carga.

## Componentes

- `ejecutar_proyecto.m`: ejecutor común; `false` ejecuta caso base y `true` corre además refinamiento, sensibilidad y validación.
- `matlab/configuracion_modelo.m`, `discretizacion_matriz.m`: parámetros, fuentes de potencia conservada y sistema disperso.
- `matlab/gausseidel_profesor.m`: referencia del profesor, conservada como función de comparación.
- `matlab/metodo_gauss_seidel.m`: implementación dispersa de la recurrencia GS.
- `matlab/metodo_gradiente_conjugado.m`: recurrencias CG explícitas; no usa `pcg`.
- `matlab/experimentos.m`: genera A–D, muestras de tiempo y metadatos.
- `matlab/validar_simulacion.m`: controles del ensamblaje y solucionadores.
- `matlab/graficar_experimentos.m`: cinco PDF vectoriales para los cuatro experimentos A–D (el mapa y la convergencia de A se exportan por separado), a partir de las exportaciones del modo completo.

## Compatibilidad

El registro disponible se generó con MATLAB R2025a Update 1. Se recomiendan MATLAB R2025a o posterior por el uso de Live Scripts, `exportgraphics`, `tiledlayout` y APIs de tablas modernas. No se ha comprobado compatibilidad con otros releases, sistemas operativos ni Octave.

La función `gausseidel_profesor.m` es una referencia académica y no se edita. Las funciones usan matrices dispersas y rutas construidas con `fullfile`/`mfilename`; no requieren rutas absolutas externas.
