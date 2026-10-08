function oct_write_mercator(OGCM_dir,OGCM_prefix,raw_mercator_name,...
                         mercator_type,vars_id,time,thedatemonth,Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract a subset from Mercator  in the case of hindcast 
% using python  copernicusmarine client
% Write it in a local file (keeping the classic SODA netcdf format)
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
disp(['    Writing MERCATOR file'])
%
% Get grid and time frame
%
ncid = netcdf.open(raw_mercator_name, 'NC_NOWRITE');
lon = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'longitude')));
lat = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'latitude')));
depth = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'depth')));
time = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time')));
lon=lon(:); lat=lat(:); depth=depth(:); time=time(:);
time = time / 24 + datenum(1950,1,1) - datenum(Yorig,1,1);
%
% Get SSH, U, V, TEMP, SALT
%
disp('    ...SSH')
vname=sprintf('%s',vars_id{1});
vid=netcdf.inqVarID(ncid, vname);
[~,~,dids]=netcdf.inqVar(ncid, vid);
ssh=permute(double(netcdf.getVar(ncid, vid)),numel(dids):-1:1);  % -> (time,[depth],lat,lon)
try, missval=double(netcdf.getAtt(ncid,vid,'_FillValue')); catch, missval=[]; end
if ~isempty(missval) && ~isnan(missval)
  ssh(ssh==missval)=NaN;   % raw values equal to _FillValue
end
try, scale_factor=double(netcdf.getAtt(ncid,vid,'scale_factor')); catch, scale_factor=1; end
try, add_offset=double(netcdf.getAtt(ncid,vid,'add_offset'));     catch, add_offset=0;   end
ssh = ssh.*scale_factor + add_offset;
disp('    ...U')
vname=sprintf('%s',vars_id{2});
vid=netcdf.inqVarID(ncid, vname);
[~,~,dids]=netcdf.inqVar(ncid, vid);
u=permute(double(netcdf.getVar(ncid, vid)),numel(dids):-1:1);  % -> (time,[depth],lat,lon)
try, missval=double(netcdf.getAtt(ncid,vid,'_FillValue')); catch, missval=[]; end
if ~isempty(missval) && ~isnan(missval)
  u(u==missval)=NaN;   % raw values equal to _FillValue
end
try, scale_factor=double(netcdf.getAtt(ncid,vid,'scale_factor')); catch, scale_factor=1; end
try, add_offset=double(netcdf.getAtt(ncid,vid,'add_offset'));     catch, add_offset=0;   end
u = u.*scale_factor + add_offset;
disp('    ...V')
vname=sprintf('%s',vars_id{3});
vid=netcdf.inqVarID(ncid, vname);
[~,~,dids]=netcdf.inqVar(ncid, vid);
v=permute(double(netcdf.getVar(ncid, vid)),numel(dids):-1:1);  % -> (time,[depth],lat,lon)
try, missval=double(netcdf.getAtt(ncid,vid,'_FillValue')); catch, missval=[]; end
if ~isempty(missval) && ~isnan(missval)
  v(v==missval)=NaN;   % raw values equal to _FillValue
end
try, scale_factor=double(netcdf.getAtt(ncid,vid,'scale_factor')); catch, scale_factor=1; end
try, add_offset=double(netcdf.getAtt(ncid,vid,'add_offset'));     catch, add_offset=0;   end
v = v.*scale_factor + add_offset;
disp('    ...TEMP')
vname=sprintf('%s',vars_id{4});
vid=netcdf.inqVarID(ncid, vname);
[~,~,dids]=netcdf.inqVar(ncid, vid);
temp=permute(double(netcdf.getVar(ncid, vid)),numel(dids):-1:1);  % -> (time,[depth],lat,lon)
try, missval=double(netcdf.getAtt(ncid,vid,'_FillValue')); catch, missval=[]; end
if ~isempty(missval) && ~isnan(missval)
  temp(temp==missval)=NaN;   % raw values equal to _FillValue
end
try, scale_factor=double(netcdf.getAtt(ncid,vid,'scale_factor')); catch, scale_factor=1; end
try, add_offset=double(netcdf.getAtt(ncid,vid,'add_offset'));     catch, add_offset=0;   end
temp = temp.*scale_factor + add_offset;
disp('    ...SALT')
vname=sprintf('%s',vars_id{5});
vid=netcdf.inqVarID(ncid, vname);
[~,~,dids]=netcdf.inqVar(ncid, vid);
salt=permute(double(netcdf.getVar(ncid, vid)),numel(dids):-1:1);  % -> (time,[depth],lat,lon)
try, missval=double(netcdf.getAtt(ncid,vid,'_FillValue')); catch, missval=[]; end
if ~isempty(missval) && ~isnan(missval)
  salt(salt==missval)=NaN;   % raw values equal to _FillValue
end
try, scale_factor=double(netcdf.getAtt(ncid,vid,'scale_factor')); catch, scale_factor=1; end
try, add_offset=double(netcdf.getAtt(ncid,vid,'add_offset'));     catch, add_offset=0;   end
salt = salt.*scale_factor + add_offset;
netcdf.close(ncid);  % close raw_mercator_name
%
% Create the Mercator file
%
oct_create_OGCM([OGCM_dir,OGCM_prefix,thedatemonth,'.cdf'],...
             lon,lat,lon,lat,lon,lat,depth,time,...
             squeeze(temp),squeeze(salt),squeeze(u),...
             squeeze(v),squeeze(ssh),Yorig)
%
return
