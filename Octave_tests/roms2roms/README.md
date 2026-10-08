# Pruebas de Roms2Roms_tools (oct_make_r2r, oct_r2r_ini, oct_make_h)

Se usan datos sintéticos:

- **Padre:** la grilla y el archivo de historia de `gen_test_his.py`.
  `croco_avg.00010.nc`, `croco_avg.00015.nc` y `croco_his.000N.nc` son
  enlaces al archivo de historia.
- **Hija:** la grilla `croco_grd.nc.1` creada con `oct_nested_grid`
  (refinamiento 3).

Los scripts `t_*.m` son copias de `oct_make_r2r`, `oct_make_r2r_inter`,
`oct_r2r_ini` y `oct_make_h`; solo cambian las rutas.

**Resultados:**

- `check_bry.py` compara las fronteras con una interpolación independiente en
  Python (triangulación lineal en lon/lat más interpolación vertical). Las
  diferencias son de 1e-5 a 1e-3, debidas a la proyección gnomónica y a la
  diagonal de los triángulos.
- **Campos lineales:** u, v, temp y zeta del padre se reemplazaron por funciones
  lineales de lon/lat. Las fronteras y el archivo inicial reproducen la función
  con un error de 1e-5 a 1e-4.
- **Archivo inicial en 2×2 bloques:** coincide con el de 1 bloque.
- **`oct_make_r2r_inter`:** produce lo mismo que `oct_make_r2r`.
- **`oct_make_h`:**
  - en las fronteras abiertas, la topografía de la hija coincide con la del
    padre (±0.3 m);
  - r < rmax.
