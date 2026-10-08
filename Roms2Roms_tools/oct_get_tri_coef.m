function [elem,coef,nnel] = oct_get_tri_coef(lonp,latp,lonc,latc,maskp)
%
% Inputs:
%          parent lon and lat 2d arrays (lonp, latp)
%          child lon and lat 2d arrays (lonc, latc)
%          parent mask (maskp)
% Ouputs:
%          elem - pointers to 2d gridded data (at lonp,latp locations) from
%                 which the interpolation is computed (3 for each child point)
%          coef - linear interpolation coefficients
%          nnel - 2d pointer to the nearest non-masked neighbor (parent grid)
%
%  Use:    Fc = sum(coef.*Fp(elem),3);
%
%   (c) 2007, Jeroen Molemaker, UCLA
%   Octave version (Oct-2026): tsearchn/dsearchn/delaunay of Octave.
%-------------------------------------------------------------------------
[Mp,Lp] = size(lonp);
[Mc,Lc] = size(lonc);
%
%  Gnomonic projection for accurate distances
%
width = max([max(lonp(:))-min(lonp(:)) max(latp(:))-min(latp(:)) ...
             max(lonc(:))-min(lonc(:)) max(latc(:))-min(latc(:))]);
if width<100
  lon0 = mean(lonc(:));
  lat0 = mean(latc(:));
  [xp,yp] = oct_gnomonic(lonp,latp,lon0,lat0);
  [xc,yc] = oct_gnomonic(lonc,latc,lon0,lat0);
else
  disp('too big for gnomonic projection')
  xp = lonp; yp = latp;
  xc = lonc; yc = latc;
end
Xp = [xp(:) yp(:)];
Xc = [xc(:) yc(:)];
tri = delaunay(xp(:),yp(:));
[tn,pn] = tsearchn(Xp,tri,Xc);
%
% Child points outside the parent grid (they should be masked!)
%
if any(~isfinite(tn))
  disp('Warning in get_tri_coef: outside point(s) detected.');
  [xc,yc] = oct_fix_outside_child(xc,yc,tn);
  Xc = [xc(:) yc(:)];
  [tn,pn] = tsearchn(Xp,tri,Xc);
end
elem = reshape(tri(tn,:),Mc,Lc,3);
coef = reshape(pn,Mc,Lc,3);
%
% Nearest non-masked parent neighbor: move the masked points far away
% and re-triangulate
%
xpm = xp; ypm = yp;
xpm(maskp==0) = xpm(maskp==0) + 1e4;
ypm(maskp==0) = ypm(maskp==0) + 1e4;
trim = delaunay(xpm(:),ypm(:));
nnel = dsearchn([xpm(:) ypm(:)],trim,Xp);
nnel = reshape(nnel,Mp,Lp);
return
