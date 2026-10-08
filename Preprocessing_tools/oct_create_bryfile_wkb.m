function oct_create_bryfile_wkb(brywkbname,grdname,title,wkb_obc,...
                        time,cycle,clobber,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function oct_create_bryfile(brywkbname,grdname,title,wkb_obc...
%                          time,cycle,clobber);
%
%   This function create the header of a Netcdf climatology 
%   file.
%
%   Input:
%
%   brywkbname   Netcdf climatology file name (character string).
%   grdname      Netcdf grid file name (character string).
%   wk_bobc      wkb open boundaries flag (1=open , [S E N W]).
%   time         time.(vector)
%   cycle        Length (days) for cycling the climatology.(Real)
%   clobber      Switch to allow or not writing over an existing
%                file.(character string)
% 
%  Further Information:  
%  http://www.brest.ird.fr/Roms_tools/
%  
%  This file is part of ROMSTOOLS
%
%  ROMSTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  ROMSTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Creating the file : ',brywkbname])
disp(' ')
%
% options for oct_write_time_attributes
insecond = 0;
add_cycle = 1 ; 
%
% Initialize Yorig if not provided
if ~exist('Yorig', 'var') ,  Yorig = [] ; , end
  %
  % Get time attributes
  [time_unit_att,time_second_unit_att,calendar_att]=...
                      oct_get_time_attributes(Yorig);
%
%  Read the grid file
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
[~,Lp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,Mp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
status=close(ncid);
L=Lp-1;
M=Mp-1;
%
%  Create the boundary file
%
type = 'WKB BOUNDARY file' ; 
history = 'CROCO' ;
ncid = netcdf.create(brywkbname, 'NC_CLOBBER');
%result = redef(nc);
%
%  Create dimensions
%
did_xi_u = netcdf.defDim(ncid, 'xi_u', L);
did_xi_v = netcdf.defDim(ncid, 'xi_v', Lp);
did_xi_rho = netcdf.defDim(ncid, 'xi_rho', Lp);
did_eta_u = netcdf.defDim(ncid, 'eta_u', Mp);
did_eta_v = netcdf.defDim(ncid, 'eta_v', M);
did_eta_rho = netcdf.defDim(ncid, 'eta_rho', Mp);
did_brywkb_time = netcdf.defDim(ncid, 'brywkb_time', length(time));
did_one = netcdf.defDim(ncid, 'one', 1);
%
%  Create variables and attributes
%
vid_tstart = netcdf.defVar(ncid, 'tstart', 'NC_DOUBLE', did_one);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'tstart'), 'long_name', 'start processing day');
oct_write_time_attributes(ncid,'tstart','',time_unit_att,time_second_unit_att,...
                      calendar_att,0,0);
%
vid_tend = netcdf.defVar(ncid, 'tend', 'NC_DOUBLE', did_one);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'tend'), 'long_name', 'end processing day');
oct_write_time_attributes(ncid,'tend','',time_unit_att,time_second_unit_att,...
                      calendar_att,0,0);
%
vid_brywkb_time = netcdf.defVar(ncid, 'brywkb_time', 'NC_DOUBLE', did_brywkb_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'brywkb_time'), 'long_name', 'time for boundary climatology');
oct_write_time_attributes(ncid,'brywkb_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);

if wkb_obc(1)==1
%
%   Southern boundary
%
  vid_wac_south = netcdf.defVar(ncid, 'wac_south', 'NC_DOUBLE', [did_xi_rho, did_brywkb_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wac_south'), 'long_name', 'southern boundary wave action density');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wac_south'), 'units', 'meter^3 second^-1');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wac_south'), 'coordinates', 'lon_rho brywkb_time');
%
  vid_wkx_south = netcdf.defVar(ncid, 'wkx_south', 'NC_DOUBLE', [did_xi_rho, did_brywkb_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wkx_south'), 'long_name', 'southern boundary xi-dir wavenumber vector');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wkx_south'), 'units', 'radian/meter');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wkx_south'), 'coordinates', 'lon_rho brywkb_time');
%
  vid_wke_south = netcdf.defVar(ncid, 'wke_south', 'NC_DOUBLE', [did_xi_rho, did_brywkb_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wke_south'), 'long_name', 'southern boundary eta-dir wavenumber vector');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wke_south'), 'units', 'radian/meter');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wke_south'), 'coordinates', 'lon_rho brywkb_time');
%
end
%
if wkb_obc(2)==1
%
%   Eastern boundary
%
  vid_wac_east = netcdf.defVar(ncid, 'wac_east', 'NC_DOUBLE', [did_eta_rho, did_brywkb_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wac_east'), 'long_name', 'eastern boundary wave action density');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wac_east'), 'units', 'meter^3 second^-1');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wac_east'), 'coordinates', 'lat_rho brywkb_time');
%
  vid_wkx_east = netcdf.defVar(ncid, 'wkx_east', 'NC_DOUBLE', [did_eta_rho, did_brywkb_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wkx_east'), 'long_name', 'eastern boundary xi-dir wavenumber vector');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wkx_east'), 'units', 'radian/meter');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wkx_east'), 'coordinates', 'lat_rho brywkb_time');
%
  vid_wke_east = netcdf.defVar(ncid, 'wke_east', 'NC_DOUBLE', [did_eta_rho, did_brywkb_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wke_east'), 'long_name', 'eastern boundary eta-dir wavenumber vector');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wke_east'), 'units', 'radian/meter');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wke_east'), 'coordinates', 'lat_rho brywkb_time');
%
end
%
if wkb_obc(3)==1
%
%   Northern boundary
%
  vid_wac_north = netcdf.defVar(ncid, 'wac_north', 'NC_DOUBLE', [did_xi_rho, did_brywkb_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wac_north'), 'long_name', 'northern boundary wave action density');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wac_north'), 'units', 'meter^3 second^-1');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wac_north'), 'coordinates', 'lon_rho brywkb_time');
%
  vid_wkx_north = netcdf.defVar(ncid, 'wkx_north', 'NC_DOUBLE', [did_xi_rho, did_brywkb_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wkx_north'), 'long_name', 'northern boundary xi-dir wavenumber vector');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wkx_north'), 'units', 'radian/meter');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wkx_north'), 'coordinates', 'lon_rho brywkb_time');
%
  vid_wke_north = netcdf.defVar(ncid, 'wke_north', 'NC_DOUBLE', [did_xi_rho, did_brywkb_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wke_north'), 'long_name', 'northern boundary eta-dir wavenumber vector');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wke_north'), 'units', 'radian/meter');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wke_north'), 'coordinates', 'lon_rho brywkb_time');
%
end
%
if wkb_obc(4)==1
%
%   Western boundary
%
  vid_wac_west = netcdf.defVar(ncid, 'wac_west', 'NC_DOUBLE', [did_eta_rho, did_brywkb_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wac_west'), 'long_name', 'western boundary wave action density');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wac_west'), 'units', 'meter^3 second^-1');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wac_west'), 'coordinates', 'lat_rho brywkb_time');
%
  vid_wkx_west = netcdf.defVar(ncid, 'wkx_west', 'NC_DOUBLE', [did_eta_rho, did_brywkb_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wkx_west'), 'long_name', 'western boundary xi-dir wavenumber vector');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wkx_west'), 'units', 'radian/meter');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wkx_west'), 'coordinates', 'lat_rho brywkb_time');
%
  vid_wke_west = netcdf.defVar(ncid, 'wke_west', 'NC_DOUBLE', [did_eta_rho, did_brywkb_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wke_west'), 'long_name', 'western boundary eta-dir wavenumber vector');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wke_west'), 'units', 'radian/meter');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'wke_west'), 'coordinates', 'lat_rho brywkb_time');
%
end
%
%
% Create global attributes
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'title', title);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'date', date);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'clim_file', brywkbname);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'grd_file', grdname);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'type', type);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'history', history);
%
% Leave define mode
%
%result = endef(nc);
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'tstart'), min([min(time) min(time) min(time)]));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'tend'), max([max(time) max(time) max(time)]));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'brywkb_time'), time);
if wkb_obc(1)==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wac_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wkx_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wkx_south'), 0);
end 
if wkb_obc(2)==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wac_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wkx_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wke_east'), 0);
end 
if wkb_obc(3)==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wac_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wkx_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wke_north'), 0);
end 
if wkb_obc(4)==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wac_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wkx_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wke_west'), 0);
end 
netcdf.close(ncid);
return


