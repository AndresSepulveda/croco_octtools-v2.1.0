%
%  This script takes hraw from the child grid file and applies log-based smoothing
%  to satisfy the max r-factor criterium (rmax) and sets a minimum depth (hmin)
%
%  Afterwards it matches child topography with that of the parent on each of its 
%  boundaries taking into account land masked areas.
%
%  Octave version (Oct-2026): calls the scripts oct_lsmooth and
%  oct_mod_cgrid (netcdf.* API of octave-netcdf).
%
%-------------------------------------------------------------------


% ROMS parent and child grid directories
pdir = '/home/livecroco/Desktop/Run/CROCO_FILES/';
cdir = '/home/livecroco/Desktop/Run/CROCO_FILES/';
pgrid = 'croco_grd.nc';
cgrid = 'croco_grd.nc.1';

% When matching boundary topo: Only match to parent topography on open boundaries
obcflag = [1 1 1 1];      % open boundaries flag (1=open , [S E N W])

rmax = 0.25;
hmin = 75;

pgrid = [pdir pgrid]
cgrid = [cdir cgrid]

gridfile = cgrid;
oct_lsmooth

if exist('pgrid','var')
   oct_mod_cgrid
end
