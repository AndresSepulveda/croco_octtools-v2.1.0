function limits = oct_r2r_bry_subgrid(parentgrid,childgrid,obcflag)
%
%   Find lower and upper index in i and j for the minimal
%   parent grid that contains all of the boundary bnd of
%   the child grid.
%
%   limits(bnd,:) = [imin imax jmin jmax]  (bnd = 1:S 2:E 3:N 4:W)
%
%   (c) 2007,  Jeroen Molemaker
%   Octave version (Oct-2026): netcdf.* API of octave-netcdf (grids
%   read in Fortran order and transposed to (eta,xi)), Octave's tsearch
%   (the tsearch.m/tsrchmx.mexa64 of the original are not needed).
%
%--------------------------------------------------------------
nc = netcdf.open(childgrid,'NC_NOWRITE');
Lonc = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'lon_rho'))).';
Latc = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'lat_rho'))).';
netcdf.close(nc);
nc = netcdf.open(parentgrid,'NC_NOWRITE');
lonp = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'lon_rho'))).';
latp = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'lat_rho'))).';
netcdf.close(nc);
[Mp,Lp] = size(lonp);
tri_par = delaunay(lonp(:),latp(:));
limits = zeros(4,4);
for bnd = 1:4
  if ~obcflag(bnd)
    continue
  end
  switch bnd
    case 1    %% South
      lonc = Lonc(1:2,:);       latc = Latc(1:2,:);
    case 2    %% East
      lonc = Lonc(:,end-1:end); latc = Latc(:,end-1:end);
    case 3    %% North
      lonc = Lonc(end-1:end,:); latc = Latc(end-1:end,:);
    case 4    %% West
      lonc = Lonc(:,1:2);       latc = Latc(:,1:2);
  end
  t = tsearch(lonp(:),latp(:),tri_par,lonc(:),latc(:));
%
% Child points that are outside the parent grid (should be masked!)
%
  if any(~isfinite(t))
    disp('Warning in r2r_bry_subgrid: outside point(s) detected.');
    [lonc,latc] = oct_fix_outside_child(lonc,latc,t);
    t = tsearch(lonp(:),latp(:),tri_par,lonc(:),latc(:));
  end
  index = tri_par(t,:);
  [idxj,idxi] = ind2sub([Mp Lp], index);
  limits(bnd,1) = min(idxi(:));
  limits(bnd,2) = max(idxi(:));
  limits(bnd,3) = min(idxj(:));
  limits(bnd,4) = max(idxj(:));
end
return
