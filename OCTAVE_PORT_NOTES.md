# croco_tools en GNU Octave con octave-netcdf

Revisión y corrección de las rutinas `oct_*` (septiembre 2026).

## Cómo usar

```
pkg install -forge netcdf      % una vez
```

`oct_start.m` ahora hace `pkg load netcdf` (antes cargaba `octcdf`, que ya no se usa)
y agrega `Opendap_tools_no_loaddap` al path. Después, en el directorio de corrida:

```
oct_start
oct_make_grid
oct_make_forcing   % o oct_make_bulk / oct_make_ERA5
oct_make_clim
oct_make_ini
oct_make_bry
oct_make_tides
oct_make_OGCM_SODA % o oct_make_OGCM_mercator
```

Probado con GNU Octave 8.4.0 y octave-netcdf 1.0.17 (la API `netcdf.*` es la misma
en 1.0.20). No hubo acceso a los datos reales de CROCO (etopo2, COADS05, WOA2009,
TPXO7, SODA, CMEMS, ERA5): las pruebas usan datos sintéticos con el mismo formato
(carpeta `Octave_tests/`).

## Diagnóstico de las rutinas oct_ existentes

El port de 2020 (octcdf) y su conversión automática posterior a `netcdf.*` tenían
errores sistemáticos. En las 537 rutinas `oct_*`:

1. **94 archivos no parseaban en Octave** (líneas rotas por el convertidor, p. ej.
   `netcdf.putVar(ncid, id, l,:,:,:-1, 1, x);  % [conv] 0-based`). Quedan 71, todos
   fuera de la cadena principal.
2. **Orden de dimensiones invertido.** `netcdf.getVar` devuelve los datos en orden
   Fortran (`xi, eta, s, time`), al revés que `nc{'var'}(:)` del netcdf-toolbox.
   Los arreglos se usaban sin transponer, y `oct_create_grid` definía las variables
   como `[eta xi]`, así que el archivo quedaba `h(xi_rho, eta_rho)`, que CROCO no
   puede leer.
3. **Índices perdidos.** Lecturas como `nc{v}(l,k,j,i2)` se convirtieron en
   `netcdf.getVar(ncid, varid)` sin `start/count`: se leía el arreglo entero en cada
   iteración, con resultados incorrectos.
4. **Restos de sintaxis octcdf/netcdf-toolbox**: `nc_clm{'temp'}(tout,:,:,:)=…`,
   `ncdouble(...)`, `sync(nc)`, `ncc.FillValue_(:)`, `ncid.components(:)`,
   `dim(nc{v})`, y `eval(['netcdf.getAtt(...)= ncchar(...)'])`.
5. **Funciones que no existen**: `netcdf.inqDimLen` (85 archivos),
   `netcdf.getVar(...,'double')` (hacía fallar siempre `oct_readdap`, y con ello la
   descarga SODA), `datetime` (`oct_nc_add_globatt`) y `bitmax` (m_map).
6. **`netcdf.putVar(ncid, id, 0)` para inicializar arreglos.** octave-netcdf no
   verifica el tamaño y **escribe memoria basura** en el archivo (verificado). Pasaba
   en `create_climfile`, `create_bryfile`, `create_inifile`, `create_oafile`,
   `create_bry_Z` y en `tide_Pphase` para las componentes de largo período.
7. **Modo de definición**: `netcdf.reDef` justo después de `netcdf.create` (error),
   falta de `netcdf.endDef`, atributos agregados a archivos existentes sin `reDef`,
   y `oct_write_time_attributes(ncid,…)` con el id del archivo equivocado.
8. **Detección de Octave rota**: `exist('octave_config_info')` vale 0 en Octave ≥ 7,
   así que `isoctave` era falso y se ejecutaban ramas solo para Matlab. Además,
   `oct_getpot` procesaba solo el primer registro cuando detectaba Octave.
9. **Escapes de shell** `eval(['!cp ...'])` y `!cmd`, que Octave no acepta.
10. **Texto alterado por el renombrado**: 'oct_start processing day', 'oct_parent',
    'oct_netcdf', 'oct_ellipse', y el programa externo `oct_ppm2fli`.
11. Otros: `netcdf.getAtt` lanza un error si el atributo no existe (el toolbox
    devolvía `[]`). `getVar` no aplica `_FillValue→NaN` ni `scale_factor`, y devuelve
    `single`/`int16` sin convertir a `double`.

## Correcciones aplicadas a todo el árbol

- Detección de Octave: `isoctave=(exist('OCTAVE_VERSION','builtin')~=0)`.
- `[~,n]=netcdf.inqDim(...)` en lugar de `netcdf.inqDimLen` (asignaciones simples).
- Llamadas al sistema: `!cmd` y `eval(['!...'])` no son válidas en Octave. La creación de
  directorios (`!mkdir` en `crocotools_param.m`, llamado desde `oct_make_grid`, y
  `system(['mkdir ',dir])` en 12 rutinas de descarga) usa ahora la función interna
  `if ~exist(dir,'dir'), mkdir(dir); end`. Las copias del spin-up en `oct_make_OGCM_SODA`,
  `oct_make_OGCM_mercator` y `oct_make_ERA5` usan `copyfile`, y el borrado en
  `oct_get_file_python_mercator` usa `delete`. El resto de las llamadas usa `system(...)`.
- Limpieza del texto alterado en `disp`, `error` y atributos.
- `flipdim` → `flip`; `finite`/`setstr` → `isfinite`/`char` (T_TIDE); `bitmax` →
  `flintmax` (m_map).

## Rutinas reescritas y probadas (cadena principal)

Convención usada: en todas se llama `netcdf.*` de forma explícita, con
`double(netcdf.getVar(...)).'` o `permute(...,[3 2 1])`, `start` en base 0 y
`start/count` en orden Fortran (`[xi eta s time]`). Al escribir se transpone o se
permuta de vuelta.

- Grilla: `oct_create_grid`, `oct_make_grid`, `oct_get_metrics`, `oct_add_topo`,
  `oct_make_coast`, `oct_easy` (E/S; la GUI `.fig` no funciona en Octave).
- COADS: `oct_create_forcing`, `oct_create_bulk`, `oct_ext_data`,
  `oct_make_forcing`, `oct_make_bulk`.
- Clim/ini/bry: `oct_create_climfile`, `oct_create_oafile`, `oct_create_inifile`,
  `oct_create_bryfile`, `oct_create_bry_Z`, `oct_ext_tracers`, `oct_ext_tracers_ini`,
  `oct_vinterp_clm`, `oct_getpot`, `oct_geost_currents`, `oct_bry_interp`,
  `oct_vinterp_bry`, `oct_getpot_bry`, `oct_geost_currents_bry`, `oct_rmavgssh`,
  `oct_make_clim`, `oct_make_bry`, `oct_nc_add_globatt`.
- OGCM: `oct_create_OGCM`, `oct_ext_data_OGCM`, `oct_interp_OGCM`,
  `oct_write_mercator`, `oct_write_mercator_multi`, `oct_make_OGCM_SODA`,
  `oct_make_OGCM_mercator`, `oct_readdap` (Opendap_tools_no_loaddap).
- ERA5: `oct_make_ERA5`, `oct_interp_ERA5`.
- Mareas: `oct_make_tides`, `oct_add_tidal_data`, `oct_nc_add_tides`,
  `oct_read_data_tpxo`, `oct_ext_data_sal`, `oct_plot_tide`, `oct_clm_tides`.
- Gráficos: `oct_test_clim`, `oct_test_bry`, `oct_test_forcing`.
- `oct_start.m` y `crocotools_param.m`.

Tres cambios de comportamiento a tener en cuenta:

- `oct_make_grid` también escribe `hraw` (topografía sin suavizar).
- La corrección de `uclm_time` en `oct_create_bryfile` (se escribían los atributos
  en `sclm_time`).
- `oct_make_ERA5` ahora busca el archivo del mes siguiente con `Mth_format`.

## Pruebas realizadas

- La cadena completa (grid → forcing → bulk → clim → ini → bry → tides → SODA) corre
  sin errores. Mercator (desde archivos CMEMS sintéticos, `Download_data=0`) y ERA5
  también se probaron.
- En todos los archivos generados, cada variable tiene el orden
  `(time, s, eta, xi)`, sin NaN ni valores basura (`Octave_tests/check_outputs.py`).
- Valores analíticos verificados: SST y temperatura WOA en superficie y fondo,
  empaquetado `int16` con `scale_factor`, avance de registros por mes y amplitud y
  fase M2 (incluido el factor nodal).
- Se verificó que los bordes de `bry` coinciden exactamente con `clm` (T, S, u,
  ubar, zeta).
- Se probó la descarga SODA (`oct_get_SODA_subgrid`, `oct_readdap`,
  `oct_extract_SODA`) contra un archivo local con el formato OPeNDAP de SODA.
- Las rutinas de gráficos corren sin ventana y producen PNG. Con el toolkit gnuplot,
  los NaN se dibujan en color; se recomienda `graphics_toolkit qt`.

## Pendiente

`octave_port_audit.csv` lista las 470 rutinas `oct_*` (fuera de UTILITIES), con su
estado y los problemas detectados automáticamente:

| código | problema |
|---|---|
| P | no parsea |
| T | sintaxis octcdf |
| C | línea rota por el convertidor |
| I | hiperslab perdido |
| D | orden de dimensiones sin transponer |
| Z | `putVar` escalar |
| A | id o modo de definición equivocado |
| X | función inexistente |

209 rutinas con NetCDF fuera de la cadena principal (Nesting, Visualization,
Diagnostic, Forecast, Aforc_NCEP/CFSR/ECMWF/QuikSCAT, Bio, Rivers, Coupling) siguen
**pendientes**. La detección es heurística y no encuentra todos los casos: conviene
tratar como no confiable toda rutina marcada como pendiente.

`crocotools_param.m` usa `netcdf.setDefaultFormat('FORMAT_NETCDF4')`. Si CROCO se
compiló sin NetCDF-4, cambiar a `'FORMAT_64BIT'`.

## Cambios posteriores

- `oct_ext_tracers`, `oct_ext_tracers_ini` y `oct_bry_interp` fallaban con
  `number of elements of argument start should match the number of dimensions`
  cuando el archivo anual (`temp_ann.cdf`, `salt_ann.cdf`) no tiene dimensión de
  tiempo, porque la variable es (Z,Y,X) y no (T,Z,Y,X). Ahora el número de
  dimensiones se consulta con `netcdf.inqVar` y `start/count` se arman según eso.
  Funciona con archivos 3D y 4D (probados los dos).
- Ríos (`oct_make_runoff`). Llamaba a `read_latlonmask` sin el prefijo `oct_`.
  Busqué el mismo problema en todo el árbol y agregué el prefijo en 35 llamadas
  (`read_latlonmask`, `horizslice`, `vertslice`, `hovmuller`, `time_series`,
  `vert_profile`, `readlat`, `readlon`). Además:
  - `oct_read_latlonmask` ahora transpone a (eta,xi).
  - `oct_runoff_glob_extract` transpone `FLOW_clm` y los nombres de ríos.
  - `oct_create_runoff` fue reescrita: no parseaba, y el convertidor había
    borrado los atributos `long_name` y `units`.
  - En `oct_make_runoff`, las series T/S de superficie se leen en el punto del
    río con `start/count`, y `Qbar`, `temp_src` y `salt_src` se escriben en el
    orden correcto. El río ficticio usa arreglos en vez de escalares.
  - `'fontweight','demi'` pasó a `'bold'`, porque Octave no acepta `demi`.
  Probado con el archivo real de Dai y Trenberth: en el dominio de Benguela se
  generan los ríos Orange y Doring, y `Qbar` coincide con `FLOW_clm`.
- Los nombres de función que no coincidían con el nombre del archivo (16 casos,
  por ejemplo `grid_pos` en `oct_runoff_grid_pos.m`) ahora coinciden.
- Mareas (`oct_make_tides`). Fallaba con "No such file or directory" en
  `oct_nc_add_tides` cuando `croco_frc.nc` no existía, por ejemplo al usar solo
  el archivo bulk (`makefrc=0`). Ahora, si falta el archivo de forzamiento, se
  crea uno solo de mareas con `oct_create_forcing_tideonly`. Si se corre
  `oct_make_tides` otra vez sobre un archivo que ya tiene mareas, se sobrescriben
  las variables en lugar de fallar. Si el número de componentes es distinto, se
  muestra un mensaje claro. Se probaron los tres casos.


## Interfaz gráfica de anidamiento (`oct_nestgui`)

La `nestgui` original depende de `nestgui.fig`, que Octave no puede abrir, y de
`rbbox`, que Octave no tiene. `oct_nestgui.m` construye ahora la ventana por
código:

- Tiene la misma disposición, los mismos controles (tags) y el mismo menú
  "Files" que el `.fig` original. Las posiciones se extrajeron del `.fig`.
- Los errores de cada botón se muestran en un `errordlg` y la interfaz no se
  cierra.

**Uso:**

```matlab
oct_start
oct_nestgui                              % luego Files > Parent grid
oct_nestgui('CROCO_FILES/croco_grd.nc')  % abre directamente la grilla madre
```

Hay que usar el ejecutable `octave` con el toolkit qt (`graphics_toolkit qt`);
`octave-cli` no puede mostrar controles.

**Definir la grilla hija:** "Define child" pide dos clics en el mapa, en esquinas
opuestas. Reemplaza el rectángulo que se arrastraba con `rbbox`. Zoom in funciona
igual.

**Rutinas genéricas de anidamiento.** Las `create_nested*` que dejó el
convertidor automático habían perdido variables y atributos. Se reemplazaron por:

- `oct_create_nestedfile`: crea el archivo hijo copiando la estructura del
  archivo padre (dimensiones, variables, tipos y atributos). Las dimensiones
  horizontales se toman de la grilla hija.
- `oct_nested_file`: interpola todas las variables horizontales, registro por
  registro, con `oct_interpvar3d` y `oct_interpvar4d`. La posición en la grilla C
  (rho, u, v o psi) se deduce de los nombres de las dimensiones. Si se pide,
  aplica la corrección vertical con `oct_vert_correc`.

Por eso las variables de biología (BIO/PISCES) de clim, ini y rst se interpolan
sin tener que listarlas. `oct_nested_forcing`, `_bulk`, `_clim`, `_initial`,
`_restart`, `_dust` y `_ndepo` conservan su firma, pero ahora solo llaman a
estas dos rutinas.

**Otros cambios en Nesting_tools:**

- `oct_nested_grid` transpone al leer y escribir, y escribe `grd_pos` y
  `refine_coef` como enteros.
- Los gráficos que usan `legend` están dentro de `try`, porque qt fallaba y se
  perdía la grilla hija.
- `oct_plot_nestforcing`, `oct_plot_nestbulk`, `oct_plot_nestclim`,
  `oct_plot_nestdust` y `oct_plot_nestndepo` fueron reescritas.

**Pruebas:** `Octave_tests/nesting/`, con datos sintéticos. El recorrido
completo de la interfaz produce los seis archivos `.nc.1`, sin errores de
dimensión:

- definir la hija con dos clics;
- agregar un río;
- topografía nueva y ajuste de volumen;
- interpolar la hija;
- forcing, bulk, initial, restart y clim.

El polvo se probó con un archivo sintético. `ndepo` usa la misma ruta, pero no
se probó con datos reales.
- Mareas: `oct_make_tides` fallaba con "NetCDF: Variable not found" en
  `oct_read_data_tpxo` al leer `u_r`, porque en algunos archivos TPXO no están
  todas las coordenadas `lon_u`, `lat_u`, `lon_v` y `lat_v`. Ahora
  `oct_read_data_tpxo` busca las coordenadas en este orden:
  1. las variables con el nombre de las dimensiones de la variable leída;
  2. `lon_<tipo>` / `lat_<tipo>`;
  3. `lon_r` / `lat_r`.

  En la grilla C de TPXO, `lat_u=lat_r` y `lon_v=lon_r`. Si falta `lon_u` o
  `lat_v`, se construye desplazando media celda la coordenada rho, y se avisa
  en pantalla. Se probó con tres archivos: el completo, uno sin
  `lat_u`/`lat_v`/`lon_v`, y otro con u y v sobre la grilla rho.

## Editor de máscara tierra/mar (`oct_editmask`)

`UTILITIES/mask/editmask.m` no funciona en Octave, por varias razones:

- usa `rbbox`;
- sus callbacks son cadenas que se evalúan con `eval`;
- usa las propiedades `erasemode`, `drawmode` y `backingstore`;
- lee y escribe con el antiguo toolbox `nc_*`.

`oct_editmask.m` es una versión nueva. Usa callbacks con function handles y lee
y escribe con `netcdf.*`.

**Uso:**

```matlab
oct_editmask('CROCO_FILES/croco_grd.nc','coastline_l_mask.mat')
oct_editmask('CROCO_FILES/croco_grd.nc')   % sin línea de costa
```

**Qué hace:**

- **Edición:** en coordenadas (I,J), como el original.
  - Modos: alternar tierra/mar, poner tierra, poner mar.
  - Herramientas:
    - punto/pincel: arrastrar pinta; el tamaño va de 1 a 15 celdas;
    - rectángulo: se arrastra con el mouse;
    - polígono: se cierra con doble clic, clic derecho o Enter.
- **Zoom:**
  - doble clic acerca x2;
  - clic derecho muestra toda la grilla;
  - el botón "Zoom in" permite dibujar un recuadro;
  - las flechas desplazan la vista y `+`/`-` cambian el zoom.
- **Deshacer y revertir:** Undo tiene varios niveles; Revert vuelve a la
  máscara guardada.
- **Remove isolated:** convierte en tierra los puntos de mar aislados y en mar
  los puntos de tierra rodeados de mar.
- **Panel de información:** muestra I, J, lon, lat, h y la máscara bajo el
  puntero.
- **Save:** recalcula `mask_u`, `mask_v` y `mask_psi` y escribe las cuatro
  máscaras en el orden de octave-netcdf (xi,eta). Si alguna variable falta, la
  crea.
- **Exit:** si hay cambios sin guardar, pregunta si se quieren guardar.
- **Línea de costa:** acepta `lon`/`lat`, como el `*_mask.mat` de
  `oct_make_coast`, o `C.Icst`/`C.Jcst`. Los puntos se convierten a (I,J) con
  `griddata`.

**Cambios relacionados:**

- `oct_make_grid` y `oct_make_grid_from_WRF` ahora llaman a `oct_editmask` y
  esperan con `waitfor` a que se cierre la ventana; antes usaban `pause`. Ese
  bloque (costa y editmask) se saltaba siempre en Octave. Ahora se ejecuta si el
  toolkit qt está disponible.
- `m_gshhs*.m` (`'save'`) y `oct_make_coast` guardaban los `.mat` con `save`
  sin opciones. En Octave eso produce un archivo de texto, y después
  `m_usercoast` fallaba con "load: can't read binary file". Ahora guardan con
  `'-v7'`.
- `oct_write_mask` usaba una función anidada, que Octave no admite, y definía
  las dimensiones en orden invertido. Se reescribió.
- `oct_read_mask` devuelve la máscara como `double`.

## Interfaz de visualización (`oct_croco_gui`) y Visualization_tools

**La interfaz.** Octave no puede abrir `croco_gui.fig`, así que `oct_croco_gui.m`
construye la ventana por código. Tiene la misma disposición, los mismos tags,
menús y callbacks, y las posiciones se extrajeron del `.fig`. Si un botón falla,
se muestra un `errordlg` y la ventana sigue abierta.

```matlab
oct_start
oct_croco_gui                                  % pide el archivo de historia
oct_croco_gui('CROCO_FILES/croco_his.nc')      % grilla leída del mismo archivo
oct_croco_gui('croco_avg.nc','croco_grd.nc')
```

Hay que usar `octave` con el toolkit qt; `octave-cli` no sirve.

**Lectura de los archivos.** Toda la cadena de lectura estaba sin adaptar al
orden de dimensiones de octave-netcdf, y varias rutinas usaban todavía la
sintaxis `nc{...}`. Se reescribió así:

- **`oct_get_hslice`:** lee solo el registro y el nivel pedidos, con
  `start/count` en orden Fortran, y transpone. Aplica `_FillValue`,
  `scale_factor` y `add_offset`. Con nivel 0 en una variable 3D usa la
  superficie.
- **`oct_get_depths`, `oct_get_section`, `oct_time_series` y
  `oct_vert_profile`:** los parámetros de la coordenada s (`theta_s`,
  `theta_b`, `hc`, `Tcline`, `Vtransform`, `VertCoordType`) se leen como
  atributos globales, como los escribe CROCO, o como variables, como los
  escriben las croco_tools. `zeta` se lee solo en el registro pedido.
- **`oct_get_type`:** las dimensiones de `netcdf.inqVar` vienen en orden
  Fortran y ahora se invierten. Antes todo se detectaba mal.
- **`oct_readlat` y `oct_readlon`:** devuelven el resultado en (eta,xi).
- **Variables derivadas** (`*Ke`, `*Rho`, `*Bvf`, `*Vort`, `*Pot_vort`,
  `*Psi`, `*Transport`, `*Okubo`, `*z_*`, `*Lorbacher_MLD`, `*rfactor`,
  `oct_ertel`): los campos 3D se leen solo en `tindex` y la grilla se
  transpone. En `oct_get_bvf`, `zw` se calculaba en puntos rho y ahora se
  calcula en puntos w.
- **`oct_get_xt` (Hovmöller):** guardaba las filas por `tindex` en vez de por
  posición. Ahora el tiempo va en días.

Se comprobó contra Python: la temperatura en el nivel 32 es idéntica, y u
interpolada a -50 m coincide en 1e-16.

**Gráficos:**

- **`oct_m_contourf`:** en Octave, `contourf` con NaN (tierra) dibuja
  polígonos erróneos. Ahora se rellenan los NaN, se enmascara la tierra con
  blanco y hay un respaldo si `contourf` falla.
- **`oct_draw_topo`:** una sola isóbata (por ejemplo `'500'`) se interpretaba
  como "500 niveles".
- **Líneas de corriente (vectores < 0):** m_map 1.4 no tiene
  `m_streamslice`, así que se usa `stream2`.
- **Figura activa:** la figura de la interfaz se vuelve la figura actual antes
  de dibujar. Sin eso, Octave dibujaba en otra ventana.
- **Gráficos por mouse:** "Separate plot" y las herramientas de mouse limpian
  la figura 1 antes de dibujar.
- **Animación:** se reemplazó ppmtompeg/FLI por cuadros PNG, un GIF animado y,
  si hay `ffmpeg`, un MP4.
- **Print:** genera EPS y PNG.

**Cambios globales:**

- El convertidor anterior había cambiado `delete(` por `oct_delete(` en
  `m_ungrid` (que usa `m_grid`), `export_fig`, `editmask`, `landsea` y
  `oct_easy`. Se restauró `delete(`.
- Los pares `warning off`/`warning on` ahora guardan y restauran el estado. En
  Octave, `warning on` activaba avisos de extensiones del lenguaje dentro de
  las funciones del sistema.

### Guardar figuras (`oct_savefig`)

El diálogo estándar de Octave (File > Save As) tiene un problema: al cambiar
el tipo de archivo en el menú de formatos, el nombre sugerido se queda como
`untitled.ofig`. Si no se cambia a mano, Octave graba por ejemplo un PNG en un
archivo `.ofig`.

`oct_savefig` es un diálogo propio que reemplaza a File > Save y Save As en:

- la figura separada de `oct_croco_gui` (Separate plot, Vertical section,
  Hovmuller, Time series y Vertical profile);
- las figuras hechas con `oct_horizslice`, `oct_vertslice`, `oct_hovmuller`,
  `oct_time_series` y `oct_vert_profile`.

**Qué hace:**

- La extensión del nombre sigue al formato elegido, y al escribir una
  extensión conocida en el nombre se selecciona ese formato.
- Formatos: PNG, PDF, EPS, SVG, JPEG, TIFF, GIF, PS y `.ofig`.
- Se puede elegir la resolución en los formatos raster.
- Pide confirmación antes de sobrescribir.
- Durante la sesión recuerda la carpeta, el formato y la resolución.
- **Nombre sugerido:**
  - en la interfaz, según el gráfico, por ejemplo `vsection_temp_t3` o
    `tseries_temp_z-10`;
  - fuera de ella, a partir del título.

También se puede usar solo: `oct_savefig(gcf)` o
`oct_savefig('install',gcf,'nombre')`.

## Generador interactivo de grillas (`oct_easy`)

`oct_easy.m` usaba el código de GUIDE (`gui_mainfcn` y `easy.fig`), que no
funciona en Octave. Además, el convertidor anterior había cambiado `varargin`
por `varargin_id`, y eso producía el error `'varargin_id' undefined`. La
ventana ahora se construye por código, con la misma disposición, los mismos
tags y la misma lógica:

- Los valores iniciales salen de `crocotools_param.m` o de
  `easy_grid_params.mat`.
- **Update** recalcula y grafica la grilla, y guarda los parámetros. Hay 6
  tipos de gráfico: outline, grid, topo, pn, pm y angle.
- **Apply** escribe lon/lat en `grdname` y cierra la ventana.
- La topografía se lee solo en la banda de latitudes de la grilla y funciona
  con cualquier convención de longitudes.
- Si los archivos GSHHS no están instalados, la línea de costa usa la de
  m_map.
- File > Save figure usa `oct_savefig`.

En `oct_make_grid`, la pregunta por el generador interactivo se saltaba
siempre en Octave. Ahora aparece si el toolkit qt está disponible. Se abre
`oct_easy`, y el script sigue cuando se cierra la ventana (`waitfor`, en vez
de `pause`).

## Roms2Roms_tools (R2RV2 + INIV2)

Carpeta nueva con la versión para Octave de las herramientas roms2roms:
condiciones de frontera e iniciales para una grilla hija a partir de las salidas
de un modelo padre, y empalme de la topografía de la hija con la del padre.

`oct_start` agrega la carpeta al path. Los detalles están en
`Roms2Roms_tools/README_Octave.md` y las pruebas en `Octave_tests/roms2roms/`.

## `crocotools_param.m` copiado de la versión Matlab (`oct_fix_param`)

**Problema:** muchos usuarios tienen en su carpeta Run una copia de
`crocotools_param.m` hecha para Matlab. Esa copia trae dos cosas que no
funcionan en Octave:

- `isoctave=exist('octave_config_info')`. Esa función ya no existe en
  Octave ≥ 7, así que `isoctave` vale 0 y se ejecutan las ramas de Matlab.
- `eval(['!mkdir ',CROCO_files_dir])`. En Octave `!` es el operador "not",
  así que da `syntax error ... !mkdir`.

**Solución:**

- **`oct_fix_param('crocotools_param.m')`** (en la raíz de croco_tools)
  actualiza el archivo y guarda el original en `crocotools_param.m.bak`:
  - corrige `isoctave`;
  - cambia `!mkdir` por `mkdir()`;
  - cambia otros `eval(['!cmd'])`, `!cmd` y `unix()` por `system()`.

  Imprime cada línea cambiada.
- **`oct_start`** avisa si el `crocotools_param.m` de la carpeta actual todavía
  es la versión Matlab.
- **`start.m`** (Matlab) ahora usa `system()` en vez de `!uname` y `!rm`, que
  daban error de sintaxis al leer el archivo en Octave.
- **`oct_get_Mmean`, `oct_download_GFS` y `oct_make_OGCM_mercator_frcst`**
  usaban `isoctave` sin definirla. Ahora la definen.
