function oct_write_mercator_multi(OGCM_dir,OGCM_prefix,raw_mercator_name,...
                              mercator_type,vars_id,time,thedatemonth,Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract a subset from Mercator in the case of 
% using python
% Write mercator multi files for analysis and forecast
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
%  Updated    19-May-2011 by Andres Sepulveda & Gildas Cambon
%  Updated    12-Feb-2016 by P. Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%  netcdf.getVar returns raw (packed) values in Fortran order
%  (lon,lat,[depth],time): they are permuted to the Matlab layout
%  (time,[depth],lat,lon), the fill values are set to NaN and
%  scale_factor/add_offset are applied here. Missing attributes
%  default to: no fill value, scale_factor=1, add_offset=0.
%
disp(['    Writing MERCATOR multifiles '])
%
% Set variable file names
%
fname_z=[raw_mercator_name(1:end-3),'_z.nc'];
fname_u=[raw_mercator_name(1:end-3),'_u.nc'];
fname_t=[raw_mercator_name(1:end-3),'_t.nc'];
fname_s=[raw_mercator_name(1:end-3),'_s.nc'];
%
% Get grid and time frame
%
ncid = netcdf.open(fname_u, 'NC_NOWRITE');
lon = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'longitude')));
lat = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'latitude')));
depth = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'depth')));
time = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time')));
lon=lon(:); lat=lat(:); depth=depth(:); time=time(:);
if (mercator_type == 4) | (mercator_type == 5)
  time = time / (24*60) + datenum(1900,1,1) - datenum(Yorig,1,1);
else
  time = time / 24 + datenum(1950,1,1) - datenum(Yorig,1,1);
end
netcdf.close(ncid);
%
% Get SSH, U, V, TEMP, SALT
%
disp('    ...SSH')
ncid = netcdf.open(fname_z, 'NC_NOWRITE');
vname=sprintf('%s',vars_id{1});
vid=netcdf.inqVarID(ncid, vname);
[~,~,dids]=netcdf.inqVar(ncid, vid);
ssh=permute(double(netcdf.getVar(ncid, vid)),numel(dids):-1:1);  % -> (time,[depth],lat,lon)
try, missval=double(netcdf.getAtt(ncid,vid,'_FillValue')); catch, missval=[]; end
if ~isempty(missval) && ~isnan(missval)
  ssh(ssh==missval)=NaN;   % raw values equal to _FillValue
end
scale_factor=1;
add_offset=0;
ssh = ssh.*scale_factor + add_offset;
netcdf.close(ncid);
disp('    ...U')
ncid = netcdf.open(fname_u, 'NC_NOWRITE');
vname=sprintf('%s',vars_id{2});
vid=netcdf.inqVarID(ncid, vname);
[~,~,dids]=netcdf.inqVar(ncid, vid);
u=permute(double(netcdf.getVar(ncid, vid)),numel(dids):-1:1);  % -> (time,[depth],lat,lon)
try, missval=double(netcdf.getAtt(ncid,vid,'_FillValue')); catch, missval=[]; end
if ~isempty(missval) && ~isnan(missval)
  u(u==missval)=NaN;   % raw values equal to _FillValue
end
scale_factor=1;
add_offset=0;
u = u.*scale_factor + add_offset;
netcdf.close(ncid);
disp('    ...V')
ncid = netcdf.open(fname_u, 'NC_NOWRITE');
vname=sprintf('%s',vars_id{3});
vid=netcdf.inqVarID(ncid, vname);
[~,~,dids]=netcdf.inqVar(ncid, vid);
v=permute(double(netcdf.getVar(ncid, vid)),numel(dids):-1:1);  % -> (time,[depth],lat,lon)
try, missval=double(netcdf.getAtt(ncid,vid,'_FillValue')); catch, missval=[]; end
if ~isempty(missval) && ~isnan(missval)
  v(v==missval)=NaN;   % raw values equal to _FillValue
end
scale_factor=1;
add_offset=0;
v = v.*scale_factor + add_offset;
netcdf.close(ncid);
disp('    ...TEMP')
ncid = netcdf.open(fname_t, 'NC_NOWRITE');
vname=sprintf('%s',vars_id{4});
vid=netcdf.inqVarID(ncid, vname);
[~,~,dids]=netcdf.inqVar(ncid, vid);
temp=permute(double(netcdf.getVar(ncid, vid)),numel(dids):-1:1);  % -> (time,[depth],lat,lon)
try, missval=double(netcdf.getAtt(ncid,vid,'_FillValue')); catch, missval=[]; end
if ~isempty(missval) && ~isnan(missval)
  temp(temp==missval)=NaN;   % raw values equal to _FillValue
end
scale_factor=1;
add_offset=0;
temp = temp.*scale_factor + add_offset;
netcdf.close(ncid);
disp('    ...SALT')
ncid = netcdf.open(fname_s, 'NC_NOWRITE');
vname=sprintf('%s',vars_id{5});
vid=netcdf.inqVarID(ncid, vname);
[~,~,dids]=netcdf.inqVar(ncid, vid);
salt=permute(double(netcdf.getVar(ncid, vid)),numel(dids):-1:1);  % -> (time,[depth],lat,lon)
try, missval=double(netcdf.getAtt(ncid,vid,'_FillValue')); catch, missval=[]; end
if ~isempty(missval) && ~isnan(missval)
  salt(salt==missval)=NaN;   % raw values equal to _FillValue
end
scale_factor=1;
add_offset=0;
salt = salt.*scale_factor + add_offset;
netcdf.close(ncid);
%
% Create the Mercator file
%
oct_create_OGCM([OGCM_dir,OGCM_prefix,thedatemonth,'.cdf'],...
             lon,lat,lon,lat,lon,lat,depth,time,...
             squeeze(temp),squeeze(salt),squeeze(u),...
             squeeze(v),squeeze(ssh),Yorig)
%
return
