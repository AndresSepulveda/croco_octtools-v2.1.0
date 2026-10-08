function [z]=oct_get_depths(fname,gname,tindex,type);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get the depths of the sigma levels
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
%  h and zeta are read in Fortran order and transposed to (eta,xi); only
%  the record tindex of zeta is read. The s-coordinate parameters are
%  read as global attributes (CROCO outputs) or as variables (files made
%  by croco_tools). The output z is (N,M,L).
%
ngid = netcdf.open(gname,'NC_NOWRITE');
try
  h = double(netcdf.getVar(ngid,netcdf.inqVarID(ngid,'h'))).';
catch
  netcdf.close(ngid);
  error(['h not found in ',gname])
end
netcdf.close(ngid);
[M,L] = size(h);
ncid = netcdf.open(fname,'NC_NOWRITE');
gid = netcdf.getConstant('NC_GLOBAL');
%
% zeta and hmorph at tindex
%
zeta = [];
for nm={'zeta','hmorph'}
  try
    vid = netcdf.inqVarID(ncid,nm{1});
    [~,~,dd] = netcdf.inqVar(ncid,vid);
    if numel(dd)==3
      tmp = double(netcdf.getVar(ncid,vid,[0 0 tindex-1],[L M 1])).';
    else
      tmp = double(netcdf.getVar(ncid,vid)).';
    end
    if strcmp(nm{1},'zeta'), zeta = tmp; else, h = tmp; end
  end
end
%
% s-coordinate parameters: global attribute first, then variable
%
prm = struct('theta_s',[],'theta_b',[],'Tcline',[],'hc',[]);
for nm=fieldnames(prm)'
  try
    prm.(nm{1}) = double(netcdf.getAtt(ncid,gid,nm{1}));
  catch
    try
      prm.(nm{1}) = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,nm{1})));
    end
  end
  if ~isempty(prm.(nm{1})), prm.(nm{1}) = prm.(nm{1})(1); end
end
theta_s = prm.theta_s; theta_b = prm.theta_b;
Tcline = prm.Tcline; hc = prm.hc;
if ~isempty(Tcline)
  hc = min(min(min(h)),Tcline);
end
%
% Number of levels
%
try
  [~,N] = netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'s_rho'));
catch
  N = [];
end
%
% Vertical transform
%
s_coord = 1;
VertCoordType = '';
try
  VertCoordType = netcdf.getAtt(ncid,gid,'VertCoordType');
end
if isempty(VertCoordType)
  try
    s_coord = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'Vtransform')));
    s_coord = s_coord(1);
  catch
    try
      s_coord = double(netcdf.getAtt(ncid,gid,'Vtransform'));
    end
  end
elseif strcmp(strtrim(char(VertCoordType(:)')),'NEW')
  s_coord = 2;
end
if s_coord==2 && ~isempty(Tcline)
  hc = Tcline;
end
netcdf.close(ncid)
if isempty(theta_s) || isempty(theta_b) || isempty(hc) || isempty(N)
  error(['OCT_GET_DEPTHS: s-coordinate parameters not found in ',fname])
end
if isempty(zeta)
  zeta = 0.*h;
end
vtype = type;
if (type=='u') || (type=='v')
  vtype = 'r';
end
z = oct_zlevs(h,zeta,theta_s,theta_b,hc,N,vtype,s_coord);
if type=='u'
  z = oct_rho2u_3d(z);
end
if type=='v'
  z = oct_rho2v_3d(z);
end
return
