# Pruebas de la cadena de preprocesamiento en Octave

Datos sintéticos (no reales) para verificar que las rutinas `oct_*` leen y
escriben NetCDF correctamente con el paquete octave-netcdf.

1. `python3 gen_test_data.py` crea `DATA_IN/` (Topo/etopo2.nc, COADS05/*.cdf,
   WOA2009/*.cdf) con campos analíticos y tierra en la esquina NE.
2. Copiar `crocotools_param.m` al directorio de corrida y poner
   `DATADIR='../DATA_IN/'` y `Download_data = 0`.
3. `octave-cli gen_test_soda.m` crea archivos SODA sintéticos con `oct_create_OGCM`.
4. `octave-cli run_chain.m` ejecuta grid, forcing, bulk, clim, ini, bry, tides y SODA.
5. `python3 check_outputs.py CROCO_FILES` revisa el orden de dimensiones y NaN.

`run_plots.m` ejecuta las rutinas de gráficos (oct_test_clim, oct_test_bry,
oct_test_forcing, oct_plot_tide, oct_clm_tides) sin ventana y guarda PNG.

## Anidamiento (Nesting_tools) y la interfaz `oct_nestgui`

En `nesting/` (ejecutar desde el directorio de corrida, después de `run_chain.m`,
con `croco_grd.nc` copiado a `NEST/`):

- `run_nesting.m`: cadena completa sin interfaz (grilla hija con topografía nueva
  y ajuste de volumen, forcing, bulk, initial, clim, restart).
- `run_nest_dust.m`: crea un archivo de polvo sintético, lo anida y lo grafica.
- `run_nestgui.m`: recorre la interfaz botón por botón. Las carpetas `stubs/`
  reemplazan `questdlg`, `uigetfile` y `ginput` para que corra sin usuario.
  Necesita el toolkit qt: `xvfb-run octave --no-gui run_nestgui.m` (no `octave-cli`).
- `python3 ../check_outputs.py NEST` revisa los archivos `.nc.1`.

## Editor de máscara (`oct_editmask`)

En `editmask/`:

- `run_editmask.m` abre el editor sobre una copia de `croco_grd.nc` y simula los
  clics. Prueba estas funciones: punto, pincel, rectángulo, polígono, deshacer,
  zoom con doble clic y clic derecho, eliminar puntos aislados, guardar y salir.
  Al guardar, comprueba que `mask_u`, `mask_v` y `mask_psi` sean las de
  `uvp_masks`.

  Para correrlo: `xvfb-run octave --no-gui run_editmask.m`.
- `waitfor_stub.m` se renombra a `waitfor.m` y se agrega al path. Sirve para
  probar `oct_make_grid` respondiendo "y": toma una captura y cierra el editor.

## Visualización (`oct_croco_gui` y Visualization_tools)

- `python3 gen_test_his.py CROCO_FILES/croco_grd.nc CROCO_FILES/croco_ini.nc CROCO_FILES/croco_his.nc`
  crea un archivo de historia CROCO sintético con la misma estructura que uno
  real. Tiene 6 registros y un remolino anticiclónico que deriva hacia el oeste.
- `croco_gui/run_get_var.m` lee todas las variables y las 20 variables
  derivadas en tres niveles: z = -50 m, nivel sigma 32 y nivel 0. Con
  `octave-cli`.
- `croco_gui/run_plots_viz.m` prueba estas rutinas y guarda un PNG de cada
  gráfico:
  - `oct_horizslice`, con los 5 estilos, vectores y líneas de corriente;
  - `oct_vertslice`, `oct_hovmuller`, `oct_time_series` y `oct_vert_profile`.
- `croco_gui/run_croco_gui.m` recorre la interfaz. Los clics del mapa y los
  diálogos se simulan con los stubs de `nesting/stubs`. Para correrlo:
  `xvfb-run octave --no-gui run_croco_gui.m`.
- `croco_gui/run_savefig.m` prueba el diálogo de guardado (`oct_savefig`):
  - al cambiar el formato cambia la extensión, y al escribir una extensión
    cambia el formato;
  - el archivo sale en el formato correcto;
  - el formato elegido se recuerda para la siguiente vez.

## Generador de grillas (`oct_easy`)

En `easy/`. Hay que hacer una copia de `croco_grd.nc` antes de correrlo, porque
"Apply" lo reescribe.

- `run_easy.m` abre la ventana y prueba lo siguiente:
  - los 6 tipos de gráfico, incluida la topografía;
  - una rotación de 20°, y que una rotación mayor que 45° se limite a 45°;
  - "Apply", con la verificación de la grilla escrita;
  - que al reabrir se lean los parámetros de `easy_grid_params.mat`.
- Para probar `oct_make_grid` respondiendo "y": renombrar `waitfor_stub.m` a
  `waitfor.m` y agregarlo al path. El stub presiona "Apply" solo.
