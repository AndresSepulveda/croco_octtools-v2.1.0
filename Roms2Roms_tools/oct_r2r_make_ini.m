function oct_r2r_make_ini(par_grd,par_data,chd_grd,chd_data,   ...
                          chdscd,parscd,scoord_switch_p,scoord_switch_c,ndomx,ndomy)
%
%  Make a CROCO/ROMS initial file on a child grid from a parent record.
%
%  The original r2r_make_ini.m and r2r_make_ini_v2.m only differ in the
%  way the netcdf files are read (hyperslabs in r2r_make_ini, whole
%  variables in v2). In the Octave version both read hyperslabs: this
%  routine calls oct_r2r_make_ini_v2 (same arguments).
%
%  Octave version (Oct-2026).
%
if nargin<9,  ndomx = 1; end
if nargin<10, ndomy = 1; end
oct_r2r_make_ini_v2(par_grd,par_data,chd_grd,chd_data,chdscd,parscd,...
                    scoord_switch_p,scoord_switch_c,ndomx,ndomy);
return
