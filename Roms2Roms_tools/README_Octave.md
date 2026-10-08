# Roms2Roms_tools: versión para Octave de R2RV2 e INIV2

Estas herramientas crean archivos para una grilla hija a partir de las salidas
de un modelo padre CROCO/ROMS. Son de J. Molemaker y E. Mason (UCLA), con
modificaciones posteriores.

- **Condiciones de frontera:**
  - `oct_make_r2r`: un solo archivo.
  - `oct_make_r2r_inter`: un archivo por año.
- **Condición inicial:** `oct_r2r_ini`.
- **Topografía de la hija:** `oct_make_h` suaviza la topografía (`oct_lsmooth`)
  y la empalma con la del padre en las fronteras abiertas (`oct_mod_cgrid`).

## Uso

1. En `oct_make_r2r.m`, `oct_make_r2r_inter.m`, `oct_r2r_ini.m` y
   `oct_make_h.m` hay que editar el bloque "USER-DEFINED VARIABLES": rutas,
   parámetros de la coordenada s y fronteras abiertas.
2. En Octave:

```matlab
oct_start              % agrega Roms2Roms_tools al path
oct_make_h             % (opcional) topografía de la hija
oct_r2r_ini            % archivo inicial
oct_make_r2r           % archivo de fronteras
```

Los coeficientes de interpolación se guardan en `r2r_coefs_<frontera>.mat`.
Al empezar, `oct_make_r2r` solo borra esos archivos. El original ejecutaba
`!rm -rf *.mat`, que borraba todos los `.mat` de la carpeta.

## Cambios respecto de los originales

- **NetCDF:**
  - Se usa la API `netcdf.*` de octave-netcdf en lugar de
    `ncread`/`ncwrite`/`ncinfo` y de la antigua sintaxis `nc{'var'}(...)`, que
    Octave no tiene.
  - Del archivo padre se lee solo la subgrilla y el registro necesarios, con
    `start/count` en orden Fortran (xi, eta, s, time). El original leía las
    variables 4D completas en cada registro.
  - Las fronteras se escriben con `putVar`, comprobando el tamaño.
- **Búsqueda de triángulos:** se usa el `tsearch` propio de Octave. No hacen
  falta `tsearch.m` ni `tsrchmx.mexa64` (que era un MEX de Matlab).
- **Código común:**
  - `get_hv_coef` venía en dos copias que solo diferían en el criterio
    `mismatch` (10000 m en R2RV2, 200 m en INIV2). Ahora es un argumento de
    `oct_get_hv_coef`.
  - El código que se repetía en `r2r_hv`, `r2r_hv_inter` y `r2r_coef_inter`
    ahora está en `oct_r2r_bnd_grids`, `oct_r2r_bnd_coefs`,
    `oct_r2r_bry_fill` y `oct_r2r_bry_time`.
- **Correcciones:**
  - `zlevs3`: comparaba cadenas con `==`.
  - `CSF`: usaba `sc^2` en vez de `sc.^2`.
  - `r2r_make_ini`: con más de un bloque (`ndomx`/`ndomy` > 1), los puntos u/v
    entre bloques quedaban en 0. Ahora los bloques se solapan un punto.
  - `mod_cgrid`: los bordes de la hija quedaban fuera de la subgrilla del padre.
    Ahora se agrega un punto de margen.
  - `r2r_create_ini`: la variable `Tclinec` ahora se llama `Tcline` y se
    escribe `sc_r`.
  - `r2r_create_bry`: escribe `cycle_length` si `bry_cycle` > 0.
  - `r2r_bry_subgrid`: el nombre de la función no coincidía con el del archivo.
  - Se reemplazaron `!rm` por `delete` y `display` por `disp`.
- **`mask_ini`:** ahora es una función, `oct_mask_ini(grdname,ininame)`.
- **`r2r_make_ini` y `r2r_make_ini_v2`:** solo diferían en la forma de leer.
  `oct_r2r_make_ini` llama a `oct_r2r_make_ini_v2`.
