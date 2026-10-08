function oct_create_OGCM(fname,lonT,latT,lonU,latU,lonV,latV,depth,time,...
                      temp,salt,u,v,ssh,Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Create the OGCM file
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
%  Updated    6-Sep-2006 by Pierrick Penven
%  Updated    7-Oct-2013 by Gildas Cambon
%  Updated   14-Fev-2013 by Gildas Cambon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%  Input arrays are in the Matlab/CROCO layout (time,depth,lat,lon);
%  netcdf.defVar gets the dimensions in Fortran order (lon,lat,depth,time)
%  and the records are written with permute(...,[3 2 1]) / .'
%
missval=NaN;
disp('    Create the OGCM file')
ncid = netcdf.create(fname, 'NC_CLOBBER');   % already in define mode
did_lonT = netcdf.defDim(ncid, 'lonT', length(lonT));
did_latT = netcdf.defDim(ncid, 'latT', length(latT));
did_lonU = netcdf.defDim(ncid, 'lonU', length(lonU));
did_latU = netcdf.defDim(ncid, 'latU', length(latU));
did_lonV = netcdf.defDim(ncid, 'lonV', length(lonV));
did_latV = netcdf.defDim(ncid, 'latV', length(latV));
did_depth = netcdf.defDim(ncid, 'depth', length(depth));
did_time = netcdf.defDim(ncid, 'time', length(time));
%
id = netcdf.defVar(ncid, 'temp', 'NC_FLOAT', [did_lonT, did_latT, did_depth, did_time]);
netcdf.putAtt(ncid, id, 'long_name', 'TEMPERATURE');
netcdf.putAtt(ncid, id, 'units', 'deg. C');
netcdf.putAtt(ncid, id, 'missing_value', single(missval));
id = netcdf.defVar(ncid, 'salt', 'NC_FLOAT', [did_lonT, did_latT, did_depth, did_time]);
netcdf.putAtt(ncid, id, 'long_name', 'SALINITY');
netcdf.putAtt(ncid, id, 'units', 'ppt');
netcdf.putAtt(ncid, id, 'missing_value', single(missval));
id = netcdf.defVar(ncid, 'u', 'NC_FLOAT', [did_lonU, did_latU, did_depth, did_time]);
netcdf.putAtt(ncid, id, 'long_name', 'ZONAL VELOCITY');
netcdf.putAtt(ncid, id, 'units', 'm/sec');
netcdf.putAtt(ncid, id, 'missing_value', single(missval));
id = netcdf.defVar(ncid, 'v', 'NC_FLOAT', [did_lonV, did_latV, did_depth, did_time]);
netcdf.putAtt(ncid, id, 'long_name', 'MERIDIONAL VELOCITY');
netcdf.putAtt(ncid, id, 'units', 'm/sec');
netcdf.putAtt(ncid, id, 'missing_value', single(missval));
id = netcdf.defVar(ncid, 'ubar', 'NC_FLOAT', [did_lonU, did_latU, did_time]);
netcdf.putAtt(ncid, id, 'long_name', 'ZONAL BAROTROPIC VELOCITY');
netcdf.putAtt(ncid, id, 'units', 'm/sec');
netcdf.putAtt(ncid, id, 'missing_value', single(missval));
id = netcdf.defVar(ncid, 'vbar', 'NC_FLOAT', [did_lonV, did_latV, did_time]);
netcdf.putAtt(ncid, id, 'long_name', 'MERIDIONAL BAROTROPIC VELOCITY');
netcdf.putAtt(ncid, id, 'units', 'm/sec');
netcdf.putAtt(ncid, id, 'missing_value', single(missval));
id = netcdf.defVar(ncid, 'ssh', 'NC_FLOAT', [did_lonT, did_latT, did_time]);
netcdf.putAtt(ncid, id, 'long_name', 'SEA LEVEL HEIGHT');
netcdf.putAtt(ncid, id, 'units', 'm');
netcdf.putAtt(ncid, id, 'missing_value', single(missval));
id = netcdf.defVar(ncid, 'lonT', 'NC_DOUBLE', did_lonT);
netcdf.putAtt(ncid, id, 'units', 'degrees_east');
id = netcdf.defVar(ncid, 'latT', 'NC_DOUBLE', did_latT);
netcdf.putAtt(ncid, id, 'units', 'degrees_north');
id = netcdf.defVar(ncid, 'lonU', 'NC_DOUBLE', did_lonU);
netcdf.putAtt(ncid, id, 'units', 'degrees_east');
id = netcdf.defVar(ncid, 'latU', 'NC_DOUBLE', did_latU);
netcdf.putAtt(ncid, id, 'units', 'degrees_north');
id = netcdf.defVar(ncid, 'lonV', 'NC_DOUBLE', did_lonV);
netcdf.putAtt(ncid, id, 'units', 'degrees_east');
id = netcdf.defVar(ncid, 'latV', 'NC_DOUBLE', did_latV);
netcdf.putAtt(ncid, id, 'units', 'degrees_north');
id = netcdf.defVar(ncid, 'depth', 'NC_DOUBLE', did_depth);
netcdf.putAtt(ncid, id, 'units', 'meters');
id = netcdf.defVar(ncid, 'time', 'NC_DOUBLE', did_time);
netcdf.putAtt(ncid, id, 'units', ['days since ',sprintf('%04d', Yorig),'-01-01 00:00:00']);
netcdf.putAtt(ncid, id, 'calendar', 'proleptic_gregorian');
netcdf.endDef(ncid);
%
% Fill the file
%
disp('    Fill the OGCM file')
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'depth'), depth);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'latT'), latT);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lonT'), lonT);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'latU'), latU);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lonU'), lonU);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'latV'), latV);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lonV'), lonV);
NZ=length(depth);
nxT=length(lonT); nyT=length(latT);
nxU=length(lonU); nyU=length(latU);
nxV=length(lonV); nyV=length(latV);
for tndx=1:length(time)
%
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'time'), tndx-1, 1, time(tndx));
%
  if length(time)==1
    ssh1=ssh;
    u1=u;
    v1=v;
    temp1=temp;
    salt1=salt;
  else
    ssh1=squeeze(ssh(tndx,:,:));
    u1=squeeze(u(tndx,:,:,:));
    v1=squeeze(v(tndx,:,:,:));
    temp1=squeeze(temp(tndx,:,:,:));
    salt1=squeeze(salt(tndx,:,:,:));
  end
  u1=reshape(u1,NZ,nyU,nxU);
  v1=reshape(v1,NZ,nyV,nxV);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ssh'),  [0 0 tndx-1],   [nxT nyT 1],    reshape(ssh1,nyT,nxT).');
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'u'),    [0 0 0 tndx-1], [nxU nyU NZ 1], permute(u1,[3 2 1]));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'v'),    [0 0 0 tndx-1], [nxV nyV NZ 1], permute(v1,[3 2 1]));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'temp'), [0 0 0 tndx-1], [nxT nyT NZ 1], permute(reshape(temp1,NZ,nyT,nxT),[3 2 1]));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'salt'), [0 0 0 tndx-1], [nxT nyT NZ 1], permute(reshape(salt1,NZ,nyT,nxT),[3 2 1]));
%
% Compute the barotropic velocities
%
  masku=isfinite(u1);
  maskv=isfinite(v1);
  u1(isnan(u1))=0;
  v1(isnan(v1))=0;
  dz=gradient(depth);
  du=zeros(nyU,nxU);
  zu=du;
  dv=zeros(nyV,nxV);
  zv=dv;
  for k=1:NZ
    du=du+dz(k)*squeeze(u1(k,:,:));
    zu=zu+dz(k)*squeeze(masku(k,:,:));
    dv=dv+dz(k)*squeeze(v1(k,:,:));
    zv=zv+dz(k)*squeeze(maskv(k,:,:));
  end
  du(zu==0)=NaN;
  dv(zv==0)=NaN;
  zu(zu==0)=NaN;
  zv(zv==0)=NaN;
  ubar=du./zu;
  vbar=dv./zv;
%
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ubar'), [0 0 tndx-1], [nxU nyU 1], reshape(ubar,nyU,nxU).');
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'vbar'), [0 0 tndx-1], [nxV nyV 1], reshape(vbar,nyV,nxV).');
%
end
netcdf.close(ncid);
return
