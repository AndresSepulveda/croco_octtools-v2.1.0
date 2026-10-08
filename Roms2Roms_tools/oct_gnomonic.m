function [xg,yg] = oct_gnomonic(lon,lat,lon0,lat0)
%
%  Gnomonic projection is distance preserving for
%  interpolation purposes.
%
%  Input:  lon,lat in degrees. lon0,lat0 centered for the domain.
%
%  (c) 2007 Jeroen Molemaker, UCLA
%  Octave version (Oct-2026): unchanged algorithm.
%
if ( max(lon(:))-min(lon(:)) > 100 ) || ( max(lat(:))-min(lat(:)) > 100 )
  disp('This area is too large for gnomonic projections!!')
  xg = lon;
  yg = lat;
  return
end
lat  = lat*pi/180;
lon  = lon*pi/180;
lat0 = lat0*pi/180;
lon0 = lon0*pi/180;
cosc = sin(lat0)*sin(lat) + cos(lat0)*cos(lat).*cos(lon-lon0);
xg = cos(lat).*sin(lon-lon0)./cosc;
yg = (cos(lat0)*sin(lat) - sin(lat0)*cos(lat).*cos(lon-lon0))./cosc;
return
