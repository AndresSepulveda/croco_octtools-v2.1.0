%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create and fill a netcdf TPXO file ready for CROCO
% 
%  Further Information:  
%  http://www.crocoagrif.org/croco_tools/
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
%  2015  Patrick Marchesiello  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%
%  Title
%
title='OTIS Mediterranian tidal elevation/currents file';
%
%  Original TPXO files
%
hfname='DATA/hf.Med2011.nc';
uvname='DATA/uv.Med2011.nc';
grdname='DATA/gridMed.nc';
%
%  Output TPXO file for CROCO pre-processing
%
outname='OTIS_Med.nc';
%
%  Period of tidal components in TPXO files:
%     "M2 S2 N2 K2 K1 O1 P1 Q1 Mf Mm" ;
%
components = 'M2 S2 N2 K2 K1 O1 P1 Q1 Mf Mm' ;
periods = [12.4206 12 12.6583 11.9672 23.9345 25.8193 24.0659 26.8684 ...
           327.8599, 661.31 ]; 
%
%----------------------------------------------------------------------
%  Read original TPXO files
%----------------------------------------------------------------------
%
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
lon=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_z')));
lat=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_z')));
h=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hz'));
h=permute(h,[2 1]);
netcdf.close(ncid);

ncid = netcdf.open(hfname, 'NC_NOWRITE');
ssh_r=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hRe'));
ssh_i=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hIm'));
ssh_r=permute(ssh_r,[1 3 2]);
ssh_i=permute(ssh_i,[1 3 2]);
netcdf.close(ncid);

ncid = netcdf.open(uvname, 'NC_NOWRITE');
u_r=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'URe'));
u_i=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'UIm'));
u_r=permute(u_r,[1 3 2]);
u_i=permute(u_i,[1 3 2]);
v_r=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'VRe'));
v_i=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'VIm'));
v_r=permute(v_r,[1 3 2]);
v_i=permute(v_i,[1 3 2]);
netcdf.close(ncid);

ssh_r(ssh_r==0)=NaN;
ssh_r(ssh_r==0)=NaN;
u_r(u_r==0)=NaN;
u_r(u_r==0)=NaN;
v_r(v_r==0)=NaN;
v_r(v_r==0)=NaN;

pcolor(lon,lat,squeeze(ssh_r(5,:,:)));
shading flat
colorbar

%
%----------------------------------------------------------------------
%  Create TPXO file
%----------------------------------------------------------------------
% 
[Ntides M L]=size(ssh_r);

nw_id = netcdf.create(outname, 'NC_CLOBBER');
%
%  Dimensions
%
did_lon_r = netcdf.defDim(nw_id, 'lon_r', L);
did_lat_r = netcdf.defDim(nw_id, 'lat_r', M);
did_lon_u = netcdf.defDim(nw_id, 'lon_u', L);
did_lat_u = netcdf.defDim(nw_id, 'lat_u', M);
did_lon_v = netcdf.defDim(nw_id, 'lon_v', L);
did_lat_v = netcdf.defDim(nw_id, 'lat_v', M);
did_periods = netcdf.defDim(nw_id, 'periods', Ntides);
%
%  Variables and attributes
%
vid_lon_r = netcdf.defVar(nw_id, 'lon_r', 'NC_FLOAT', did_lon_r);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_r'), 'long_name', 'Longitude at SSH points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_r'), 'units', 'degree_east');

vid_lat_r = netcdf.defVar(nw_id, 'lat_r', 'NC_FLOAT', did_lat_r);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_r'), 'long_name', 'Longitude at SSH points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_r'), 'units', 'degree_east');

vid_lon_u = netcdf.defVar(nw_id, 'lon_u', 'NC_FLOAT', did_lon_u);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_u'), 'long_name', 'Longitude at U points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_u'), 'units', 'degree_east');

vid_lat_u = netcdf.defVar(nw_id, 'lat_u', 'NC_FLOAT', did_lat_u);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_u'), 'long_name', 'Longitude at U points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_u'), 'units', 'degree_east');

vid_lon_v = netcdf.defVar(nw_id, 'lon_v', 'NC_FLOAT', did_lon_v);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_v'), 'long_name', 'Longitude at V points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_v'), 'units', 'degree_east');

vid_lat_v = netcdf.defVar(nw_id, 'lat_v', 'NC_FLOAT', did_lat_v);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_v'), 'long_name', 'Longitude at V points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_v'), 'units', 'degree_east');

vid_periods = netcdf.defVar(nw_id, 'periods', 'NC_FLOAT', did_periods);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'periods'), 'long_name', 'Tide periods');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'periods'), 'units', 'hours');

vid_h = netcdf.defVar(nw_id, 'h', 'NC_FLOAT', [did_lon_r, did_lat_r]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'h'), 'long_name', 'Final bathymetry at SSH-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'h'), 'units', 'meter');

vid_ssh_r = netcdf.defVar(nw_id, 'ssh_r', 'NC_FLOAT', [did_lon_r, did_lat_r, did_periods]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'ssh_r'), 'long_name', 'Elevation real part');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'ssh_r'), 'units', 'meter');

vid_ssh_i = netcdf.defVar(nw_id, 'ssh_i', 'NC_FLOAT', [did_lon_r, did_lat_r, did_periods]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'ssh_i'), 'long_name', 'Elevation imaginary part');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'ssh_i'), 'units', 'meter');

vid_u_r = netcdf.defVar(nw_id, 'u_r', 'NC_FLOAT', [did_lon_u, did_lat_u, did_periods]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'u_r'), 'long_name', 'U-transport component real part');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'u_r'), 'units', 'm2/s');

vid_u_i = netcdf.defVar(nw_id, 'u_i', 'NC_FLOAT', [did_lon_u, did_lat_u, did_periods]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'u_i'), 'long_name', 'U-transport component imaginary part');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'u_i'), 'units', 'm2/s');

vid_v_r = netcdf.defVar(nw_id, 'v_r', 'NC_FLOAT', [did_lon_v, did_lat_v, did_periods]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'v_r'), 'long_name', 'V-transport component real part');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'v_r'), 'units', 'm2/s');

vid_v_i = netcdf.defVar(nw_id, 'v_i', 'NC_FLOAT', [did_lon_v, did_lat_v, did_periods]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'v_i'), 'long_name', 'V-transport component imaginary part');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'v_i'), 'units', 'm2/s');
%
%  Global attributes
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'type', 'Tides file for CROCO pre-processing');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'title', title);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'date', date);
components=components(1:3*Ntides);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'components', components);

netcdf.close(nw_id);

%
%----------------------------------------------------------------------
%  Fill in TPXO file
%----------------------------------------------------------------------
%
nw_id = netcdf.open(outname, 'NC_WRITE');
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lon_r'), lon);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lat_r'), lat);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lon_u'), lon);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lat_u'), lat);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lon_v'), lon);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lat_v'), lat);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'periods'), periods(1:Ntides));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'h'), h);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'ssh_r'), ssh_r(1:Ntides,:,:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'ssh_i'), ssh_i(1:Ntides,:,:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'u_r'), u_r(1:Ntides,:,:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'u_i'), u_i(1:Ntides,:,:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'v_r'), v_r(1:Ntides,:,:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'v_i'), v_i(1:Ntides,:,:));
netcdf.close(nw_id);

