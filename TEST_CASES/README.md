# CROCO TEST_CASES plots for GNU Octave

These are Octave versions of the 34 `plot_*.m` scripts in the `TEST_CASES` folder of the
CROCO source code. Each `oct_plot_<case>.m` is the original `plot_<case>.m` with the same
figures. The changes needed to run it in Octave 8 with the `octave-netcdf` package are
described below.

## Use

Copy this folder's files into your CROCO `TEST_CASES` folder, or add this folder to the
Octave path. Then run the script from the folder that holds the model output, as with the
Matlab scripts:

```
pkg load netcdf
addpath('/path/to/croco_tools/TEST_CASES_octave')
oct_plot_upwelling          % reads upwelling_avg.nc
```

The scripts need no other croco_tools folder. The croco_tools functions they use are
included here in their Octave versions: `oct_zlevs`, `oct_csf`, `oct_u2rho_2d`,
`oct_v2rho_2d`, `oct_rho2uvp`, `oct_rho2u_2d`, `oct_psi2rho`, `oct_vorticity` and
`oct_tridim`.

## What was changed

### Reading NetCDF files

The Matlab scripts use the old NetCDF toolbox (`nc=netcdf(file)`, `nc{'var'}(...)`,
`nc.att(:)`). It is replaced by these functions, which use `octave-netcdf`:

| Matlab (old toolbox) | Octave |
|---|---|
| `nc=netcdf(fname,'r')` | `nc=oct_tc_open(fname)` |
| `nc{'h'}(:)` | `oct_tc_all(nc,'h')` |
| `nc{'u'}(t,N,:,:)` | `oct_tc_sq(oct_tc_var(nc,'u')(t,N,:,:),4,oct_tc_ndims(nc,'u'))` |
| `nc.theta_s(:)` | `oct_tc_att(nc,'theta_s')` |
| `length(nc('s_rho'))` | `oct_tc_dim(nc,'s_rho')` |
| `close(nc)` | `oct_tc_close(nc)` |

`oct_tc_var` returns the variable in the C order of the old toolbox (time, s, eta, xi).
The subscripts are applied with Octave indexing on the result, so `end` works as before.
Recently read variables are cached, so loops over time records do not read the file
again.

`oct_tc_sq` reproduces the shape of the toolbox result, as coded in
`UTILITIES/mexcdf/netcdf_toolbox/netcdf/@ncvar/subsref.m`:

- **Leading singleton dimensions are removed.** For example, `u(t,N,:,:)` is M x (L-1),
  and `bed_thick(t,:,1,1)` is a column.
- **A single remaining dimension gives a row vector.** For example, `zeta(t,j,:)` is
  1 x L, the same orientation as `h(j,:)`, which `zlevs` needs.
- **1-D variables give a column vector.** This holds whatever the subscripts are; for
  example, `scrum_time(:,:)` is still a column.

### Other replacements

- **`export_fig`** (File Exchange) is replaced by `oct_export_fig`, which saves with
  `print` and keeps the same command syntax (`oct_export_fig -transparent -pdf file.pdf`).
- **`QTWriter` / `writeMovie`** (File Exchange) are replaced by `oct_QTWriter`. The frames
  are written as PNG files, and `close(movObj)` assembles them with ffmpeg (H.264).
- **`nansum`** (Statistics toolbox) and **`padarray`** (Image toolbox) are replaced by
  `oct_nansum` and `oct_padarray`.
- **`xline` / `yline`**, which Octave 8 does not have, are replaced by `oct_xline` /
  `oct_yline`.
- **`contourf`** is replaced by `oct_contourf`. Octave 8's `contourf` stops with
  `'cont_lev' undefined` when no contour level is inside the data range; Matlab then
  draws nothing. `oct_contourf` gives a warning and the rest of the figure is still made.
- **`colorbar('h')` / `colorbar('v')`** become `colorbar('southoutside')` /
  `colorbar('eastoutside')`.
- **`set(hf,'DoubleBuffer','on')`** is removed, because it is not an Octave property.
- **Dot notation on graphics handles** (`h1.Position = h1.Position + ...`,
  `cbr.Label.String = ...`) becomes `set`/`get` and `ylabel(cbr,...)`.
- **`set(h,'color',c)` on contour objects** (plot_innershelf) uses `oct_set_color`. In
  Octave the colour of contour lines is the `linecolor` property.
- **`eval('!pdfcrop ...')`** becomes `system('pdfcrop ...')`.
- **plot_sed_toy_rouse:** the Matlab string arrays `["mud_01", ...]` become cell arrays.
- **plot_stations:** `scrum_time` is accepted as `scrum_time(time)` or
  `scrum_time(time,station)`.

The colormaps, levels, texts and layout of the figures are not changed.

## Conversion and tests

`conversion/conv_tc.py` converts a CROCO `TEST_CASES` folder:

```
python3 conversion/conv_tc.py /path/to/croco/TEST_CASES .
```

The file-specific fixes it applies are in `conversion/fixes_tc.py`. To convert the plots
of a newer CROCO version, run it again and check the scripts that changed.

`Octave_tests/test_cases` writes synthetic CROCO-like output files for every case
(`python3 cases.py`, which needs netCDF4) and runs all the scripts (`./run_all.sh`). All
34 scripts run and make their figures. Because the data are synthetic, the figures only
check that the code works, not the physics.

The preprocessing scripts of the folder (`make_jet.m`, `make_vortex.m`, `make_rip.m`,
`make_*_IGW.m`, `barocjet.m`, `barocvortex.m`) are not part of this conversion.

Andres Sepulveda 2026 - Octave adaptations
