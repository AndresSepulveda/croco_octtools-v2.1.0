function h=oct_add_speed_vec(fname,gname,tindex,level,skp,npts,...
                         scale,x0,y0,u_unit,units,...
                         fontsize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  h=oct_add_speed_vec(fname,gname,tindex,level,skp,npts,...
%                         scale,x0,y0,u_unit,units,...
%                         fontsize)
%
%  Add speed vectors on a plot.
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
hold_state = ishold;
%
% Defaults values
%

if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  disp('Default time index: 1')
  tindex=1;
end
if nargin < 3
  disp('Default level: -10 m')
  level= -10;
end
if nargin < 4
  disp('Default skip parameter: 1')
  skp=1;
end
if nargin < 5
  disp('Default boundary remove: [0 0 0 0]')
  npts=[0 0 0 0];
end
if nargin < 6
  disp('Default scale: 1')
  scale=1;
end

[lat,lon,mask]=oct_read_latlonmask(gname,'r');
ncid = netcdf.open(gname, 'NC_NOWRITE');
try
  angle=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'))).';
catch
  disp('Warning: no angle found in the grid file')
  angle=0*lat;
end
netcdf.close(ncid);
mask(mask==0)=NaN;


if level==0
  u=oct_get_hslice(fname,gname,'ubar',tindex,level,'u');
  v=oct_get_hslice(fname,gname,'vbar',tindex,level,'v');
else
  u=oct_get_hslice(fname,gname,'u',tindex,level,'u');
  v=oct_get_hslice(fname,gname,'v',tindex,level,'v');
end
[u,v,lon,lat,mask]=oct_uv_vec2rho(u,v,lon,lat,angle,mask,abs(skp),npts);
  
if nargin < 8
  u=u*scale/20;
  v=v*scale/20;
  if skp>0
   h=oct_m_quiver_cst(lon,lat,u,v,0,'k');      % vectors
  elseif exist('m_streamslice')
   h=m_streamslice(lon,lat,u,v,5*scale);   % streamlines
  else
%
%  Octave / m_map 1.4: no streamslice. Streamlines computed with stream2
%  in the map coordinates, seeded on a regular grid
%
   [x,y]=m_ll2xy(lon,lat);
   [ux,vy]=deal(u,v);
   good=isfinite(x)&isfinite(y);
   ux(~isfinite(ux))=0; vy(~isfinite(vy))=0;
   nx=max(20,round(size(x,2))); ny=max(20,round(size(x,1)));
   xi=linspace(min(x(good)),max(x(good)),nx);
   yi=linspace(min(y(good)),max(y(good)),ny);
   [XI,YI]=meshgrid(xi,yi);
   UI=griddata(x(good),y(good),ux(good),XI,YI);
   VI=griddata(x(good),y(good),vy(good),XI,YI);
   UI(isnan(UI))=0; VI(isnan(VI))=0;
   ns=max(3,round(7/scale));
   [sx,sy]=meshgrid(xi(round(linspace(2,nx-1,ns))),yi(round(linspace(2,ny-1,ns))));
   h=[];
   xy=stream2(XI,YI,UI,VI,sx(:),sy(:),[0.2 150]);
   for k=1:numel(xy)
     if size(xy{k},1)>2
       h(end+1)=line(xy{k}(:,1),xy{k}(:,2),'color','k');
     end
   end
  end
else
  h=m_quiver_fix(lon,lat,u,v,scale,x0,y0,u_unit,units,...
                         fontsize);
end

if ~hold_state, hold off; 
end
return
