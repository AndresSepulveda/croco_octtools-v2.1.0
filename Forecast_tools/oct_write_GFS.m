function oct_write_GFS(fname,Yorig,lon,lat,mask,time,tx,ty,tair,rhum,prate,wspd,uwnd,vwnd,radlw,radlw_in,radsw)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function oct_write_GFS(fname,Yorig,lon,lat,mask,time,tx,ty,...
%                     tair,rhum,prate,wspd,radlw,radsw)
%
%  Write into a GFS file
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
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    9-Sep-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp(['Create ',fname])
ncid = netcdf.create([fname], 'NC_CLOBBER');
%
did_lon = netcdf.defDim(ncid, 'lon', length(lon));
did_lat = netcdf.defDim(ncid, 'lat', length(lat));
%
% nc('latu') = length(lat);
% nc('latv') = length(lat)-1;
% nc('lonu') = length(lon)-1;
% nc('lonv') = length(lon);
%
did_time = netcdf.defDim(ncid, 'time', length(time));
%
vid_lon = netcdf.defVar(ncid, 'lon', 'NC_FLOAT', did_lon);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lon'), 'long_name', 'longitude of RHO-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lon'), 'units', 'degree_east');
% 
vid_lat = netcdf.defVar(ncid, 'lat', 'NC_FLOAT', did_lat);
vid_lat = netcdf.defVar(ncid, 'lat', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lat'), 'long_name', 'latitude of RHO-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lat'), 'units', 'degree_north');
%
vid_time = netcdf.defVar(ncid, 'time', 'NC_FLOAT', did_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'time'), 'long_name', 'Time');
eval(['netcdf.getAtt(ncid, netcdf.inqVarID(ncid, ''time''), 'units')= ncchar(''days since 1-Jan-',num2str(Yorig),' 00:00:0.0'');'])
eval(['netcdf.getAtt(ncid, netcdf.inqVarID(ncid, ''time''), 'units')= ''days since 1-Jan-',num2str(Yorig),' 00:00:0.0'';'])
%
vid_mask = netcdf.defVar(ncid, 'mask', 'NC_FLOAT', [did_lon, did_lat]);
vid_tx = netcdf.defVar(ncid, 'tx', 'NC_FLOAT', [did_lon, did_lat, did_time]);
vid_ty = netcdf.defVar(ncid, 'ty', 'NC_FLOAT', [did_lon, did_lat, did_time]);
vid_tair = netcdf.defVar(ncid, 'tair', 'NC_FLOAT', [did_lon, did_lat, did_time]);
vid_rhum = netcdf.defVar(ncid, 'rhum', 'NC_FLOAT', [did_lon, did_lat, did_time]);
vid_prate = netcdf.defVar(ncid, 'prate', 'NC_FLOAT', [did_lon, did_lat, did_time]);
vid_wspd = netcdf.defVar(ncid, 'wspd', 'NC_FLOAT', [did_lon, did_lat, did_time]);
vid_radlw = netcdf.defVar(ncid, 'radlw', 'NC_FLOAT', [did_lon, did_lat, did_time]);
vid_radsw = netcdf.defVar(ncid, 'radsw', 'NC_FLOAT', [did_lon, did_lat, did_time]);
vid_radlw_in = netcdf.defVar(ncid, 'radlw_in', 'NC_FLOAT', [did_lon, did_lat, did_time]);
vid_uwnd = netcdf.defVar(ncid, 'uwnd', 'NC_FLOAT', [did_lon, did_lat, did_time]);
vid_vwnd = netcdf.defVar(ncid, 'vwnd', 'NC_FLOAT', [did_lon, did_lat, did_time]);
%
netcdf.endDef(ncid);
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon'), lon);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat'), lat);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask'), mask);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'tx'), tx);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ty'), ty);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'tair'), tair);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'rhum'), rhum);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'prate'), prate);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wspd'), wspd);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'uwnd'), uwnd);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'vwnd'), vwnd);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'radlw'), radlw);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'radlw_in'), radlw_in);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'radsw'), radsw);
%
netcdf.close(ncid);








