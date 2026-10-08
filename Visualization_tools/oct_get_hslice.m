function var=oct_get_hslice(fname,gname,vname,tindex,level,type);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function var=oct_get_hslice(fname,vname,tindex,level,type);
%
% get an horizontal slice of a CROCO variable
%
% input:
%
%  fname    CROCO netcdf file name (average or history) (string)
%  gname    CROCO netcdf grid file name  (string)
%  vname    name of the variable (string)
%  tindex   time index (integer)
%  level    vertical level of the slice (scalar):
%             level =   integer >= 1 and <= N
%                       take a slice along a s level (N=top))
%             level =   0
%                       2D horizontal variable (like zeta)
%             level =   real < 0
%                       interpole a horizontal slice at z=level
%  type    type of the variable (character):
%             r for 'rho' for zeta, temp, salt, w(!)
%             w for 'w'   for AKt
%             u for 'u'   for u, ubar
%             v for 'v'   for v, vbar
%
% output:
%
%  var     horizontal slice (2D matrix)
%
%
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026), netcdf.* API of the octave-netcdf package.
%  Only the needed record/level is read (hyperslab with 0-based start
%  and count in Fortran order: xi, eta, s, time) and transposed to
%  (eta,xi). _FillValue is set to NaN and scale_factor/add_offset are
%  applied. For level==0 and a 3D variable, the surface level is used.
%
ncid = netcdf.open(fname,'NC_NOWRITE');
try
  varid = netcdf.inqVarID(ncid,vname);
catch
  netcdf.close(ncid);
  error(['Variable ',vname,' not found in ',fname])
end
[~,~,dimids] = netcdf.inqVar(ncid,varid);
nd = numel(dimids);
dlen = zeros(1,nd); dname = cell(1,nd);
for k=1:nd
  [dname{k},dlen(k)] = netcdf.inqDim(ncid,dimids(k));
end
[~,~,~,unlimdim] = netcdf.inq(ncid);
istime = ~isempty(strfind(dname{end},'time')) || dimids(end)==unlimdim;
if istime, nt=1; else, nt=0; end
nsp = nd-nt;                          % number of space dimensions
if nsp<2
  netcdf.close(ncid);
  error([vname,' is not a horizontal field'])
end
start = zeros(1,nd); count = dlen;
if istime
  start(end) = tindex-1; count(end) = 1;
end
if nsp==3 && level>=0
%
% s-level (level=0 for a 3D variable: surface level)
%
  N = dlen(3);
  if level>0
    start(3) = min(level,N)-1;
  else
    start(3) = N-1;
  end
  count(3) = 1;
end
var = double(netcdf.getVar(ncid,varid,start,count));
%
% Missing values, scale factor and offset
%
try
  fv = double(netcdf.getAtt(ncid,varid,'_FillValue'));
  var(var==fv) = NaN;
end
try
  var = var*double(netcdf.getAtt(ncid,varid,'scale_factor'));
end
try
  var = var+double(netcdf.getAtt(ncid,varid,'add_offset'));
end
%
% Fortran order -> (s,eta,xi) or (eta,xi)
%
if nsp==3 && level<0
  var = permute(var,[3 2 1]);
else
  var = var.';
end
if level==0 && nsp==2
%
% Mask the dry cells (wetting-drying)
%
  ngid = netcdf.open(gname,'NC_NOWRITE');
  try
    h = double(netcdf.getVar(ngid,netcdf.inqVarID(ngid,'h'))).';
  catch
    netcdf.close(ngid); netcdf.close(ncid);
    error(['h not found in ',gname])
  end
  netcdf.close(ngid);
  [M,L] = size(h);
  try
    vid = netcdf.inqVarID(ncid,'hmorph');
    [~,~,hd] = netcdf.inqVar(ncid,vid);
    if numel(hd)==3
      h = double(netcdf.getVar(ncid,vid,[0 0 tindex-1],[L M 1])).';
    else
      h = double(netcdf.getVar(ncid,vid)).';
    end
  end
  try
    vid = netcdf.inqVarID(ncid,'zeta');
    [~,~,zd] = netcdf.inqVar(ncid,vid);
    if numel(zd)==3
      zeta = double(netcdf.getVar(ncid,vid,[0 0 tindex-1],[L M 1])).';
    else
      zeta = double(netcdf.getVar(ncid,vid)).';
    end
  catch
    zeta = zeros(size(h));
  end
  D = zeta+h;
  try
    Dcrit = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'Dcrit')))+1.e-5;
  catch
    Dcrit = 0.2+1.e-5;
  end
  if type=='u'
    D = oct_rho2u_2d(D);
  elseif type=='v'
    D = oct_rho2v_2d(D);
  end
  if isequal(size(D),size(var))
    var(D<=Dcrit) = NaN;
  end
elseif level>=0
  var(var==0) = NaN;
elseif level<0
  netcdf.close(ncid);
  z = oct_get_depths(fname,gname,tindex,type);
  var = oct_vinterp(var,z,level);
  return
end
netcdf.close(ncid);
return
