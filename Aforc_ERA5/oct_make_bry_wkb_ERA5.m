%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO boundary file
%
%  Extrapole and interpole temperature and salinity from a
%  climatology to get boundary conditions for
%  CROCO (boundary netcdf file) .
%  Get the velocities and sea surface elevation via a 
%  geostrophic computation.
%
%  Data input format (netcdf):
%     temperature(T, Z, Y, X)
%     T : time [Months]
%     Z : Depth [m]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO climate Data Library (World Ocean Atlas 1998)
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NODC/.WOA98/
% 
%  Further Information:  
%  http://www.croco-ocean.org
%  
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  CROCOTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    2016 by Patrick Marchesiello & Rachid Benshila
%                     for wave forcing
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Title: ',CROCO_title])
%
% Read in the grid
%
disp(' ')
disp(' Read in the grid...')
ncid = netcdf.open(grdname, 'NC_NOWRITE');
h=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'));
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
angle=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'));
mask=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'));
[~,Lp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,Mp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
hmax=max(max(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'))));
result=close(ncid);
grid_angle=mean(mean(angle(mask==1)));
[M L]=size(h);
%
wkb_prefix=[wkb_prefix,'_ERA5_'];
frc_prefix=[frc_prefix,'_ERA5_'];
%
%
% Loop over monthly files
%
for Y=Ymin:Ymax
 if Y==Ymin 
   mo_min=Mmin;
 else
   mo_min=1;
 end
 if Y==Ymax
   mo_max=Mmax;
 else
   mo_max=12;
 end
 for M=mo_min:mo_max
%
% Forcing file name
%
  if level==0
   nc_suffix='.nc';
  else
   nc_suffix=['.nc.',num2str(level)];
  end
  frcname=[frc_prefix,'Y',num2str(Y),...
                      'M',num2str(sprintf(Mth_format,M)),nc_suffix];
%
% WKB file name
%
  brywkbname=[wkb_prefix,'Y',num2str(Y),...
                     'M',num2str(sprintf(Mth_format,M)),nc_suffix];
  disp(' ')
  disp([' Making file: ',brywkbname])
  disp(['        from: ',frcname])
%
% Read wave fields data
%
  ncid = netcdf.open(frcname, 'NC_NOWRITE');
  Awave=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Awave'));
  Dwave=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Dwave'));
  Pwave=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Pwave'));
  time =netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'wwv_time'));
  netcdf.close(ncid);

  wkb_time=time;
  wkb_cycle=0;
%
% Create the boundary file
%
  oct_create_bryfile_wkb(brywkbname,grdname,CROCO_title,wkb_obc,...
                     wkb_time,wkb_cycle,'clobber',Yorig);
  disp(' ')
%
% 
% Extract boundary data: loop on time and boundaries
% note: in ERA5, meteo convention for wave direction:
% --> zero means "coming from north" and 90 "coming from east"
%
  disp(' Extracting and writing file ...')
  ncid = netcdf.open(brywkbname, 'NC_WRITE');
  g=9.81;
  for l=1:length(time)
   for obcndx=1:4
    if obcndx==1
     suffix='_south';     % SOUTH
     Dstp=squeeze(h(1,:));
     hrm=2*squeeze(Awave(l,1,:));
     cdir=3*pi/2-deg2rad(squeeze(Dwave(l,1,:)))-grid_angle;
     cfrq=2*pi./squeeze(Pwave(l,1,:));
    elseif obcndx==2
     suffix='_east';      % EAST
     Dstp=squeeze(h(:,L));
     hrm=2*squeeze(Awave(l,:,L));
     cdir=3*pi/2-deg2rad(squeeze(Dwave(l,:,L)))-grid_angle;
     cfrq=2*pi./squeeze(Pwave(l,:,L));
    elseif obcndx==3
     suffix='_north';     % NORTH
     Dstp=squeeze(h(M,:));
     hrm=2*squeeze(Awave(l,M,:));
     cdir=3*pi/2-deg2rad(squeeze(Dwave(l,M,:)))-grid_angle;
     cfrq=2*pi./squeeze(Pwave(l,M,:));
    elseif obcndx==4
     suffix='_west';      % WEST
     Dstp=squeeze(h(:,1));
     hrm=2*squeeze(Awave(l,:,1));
     cdir=3*pi/2-deg2rad(squeeze(Dwave(l,:,1)))-grid_angle;
     cfrq=2*pi./squeeze(Pwave(l,:,1));
    end
    dd = Dstp'; %+Tide(l)
    khd = dd.*cfrq.*cfrq./g;
    kh = sqrt(    khd.*khd + khd./(1.0 + khd.*(0.6666666666 ...
                 +khd.*(0.3555555555 + khd.*(0.1608465608 ... 
                 +khd.*(0.0632098765 + khd.*(0.0217540484 ...
                 +khd.*0.0065407983)))))) );
    kw=kh./dd;
    cosw=cos(cdir);
    sinw=sin(cdir);
    wac=0.125*g*(hrm.^2)./cfrq;
    wkx=kw.*cosw;
    wke=kw.*sinw;
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, ['wac' suffix]), l,:-1, 1, wac);  % [conv] 0-based
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, ['wkx' suffix]), l,:-1, 1, wkx);  % [conv] 0-based
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, ['wke' suffix]), l,:-1, 1, wke);  % [conv] 0-based
   end
  end
  netcdf.close(ncid);

 end % M
end % Y
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
