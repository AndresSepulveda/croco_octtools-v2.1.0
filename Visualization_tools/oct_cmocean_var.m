function [name,div]=oct_cmocean_var(var)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% OCT_CMOCEAN_VAR  default cmocean colormap of a CROCO variable
%
%   [name,div] = oct_cmocean_var(VAR)
%
%   VAR : variable name (temp, salt, u, v, w, zeta, rho, NO3, CHLA ...)
%   name: cmocean colormap name (see oct_cmocean)
%   div : true for a signed variable (velocities, vorticity, zeta,
%         fluxes...) drawn with a diverging colormap and a colour range
%         symmetric around 0
%
%   temp, SST -> thermal | salt -> haline | rho, sigma -> dense
%   u, v, w, ubar, vbar, ue, vn, zeta, vorticity, fluxes -> balance (div)
%   speed, wind, stress magnitude, KE, EKE -> speed | h, depth -> deep
%   O2 -> oxy | CHLA, phytoplankton -> algae | NO3, PO4, Si, NH4 -> matter
%   zooplankton, detritus -> turbid | AKt, AKv -> amp | Hz -> deep
%   other -> thermal
%
%  Octave version (Oct-2026).
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
%  Copyright (c) 2026 by Andres Sepulveda
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<1 || isempty(var), var=''; end
v=lower(strtrim(var));
div=false;
if any(strcmp(v,{'temp','sst','t','temperature','theta','tpas'})) || ~isempty(regexp(v,'^(temp|sst)','once'))
  name='thermal';
elseif any(strcmp(v,{'salt','sss','s','salinity'})) || ~isempty(regexp(v,'^(salt|sss)','once'))
  name='haline';
elseif any(strcmp(v,{'rho','sig','sigma','sigma_t','sigmat','rho1','bvf'})) || ~isempty(regexp(v,'^(rho|sigma)','once'))
  name='dense';
elseif any(strcmp(v,{'speed','spd','wspd','ke','eke','mke','mag','magnitude','|v|'})) || ...
       ~isempty(regexp(v,'(speed|magnitude|^\|)','once'))
  name='speed';
elseif ~isempty(regexp(v,'^(u|v|w|ubar|vbar|ue|vn|u10|v10|uwnd|vwnd|uwind|vwind|taux|tauy|sustr|svstr|omega|zeta|ssh|pv|psi|bustr|bvstr|div)$','once')) ...
       || ~isempty(regexp(v,'(vort|flux|curl|anom|/)','once'))
  name='balance'; div=true;
  if ~isempty(regexp(v,'/','once')), name='speed'; div=false; end   % wind pair label: magnitude
elseif any(strcmp(v,{'h','depth','bathy','hraw','z_r','z_w','hbl','hbbl'}))
  name='deep';
elseif ~isempty(regexp(v,'^(o2|oxy|doxy)','once'))
  name='oxy';
elseif ~isempty(regexp(v,'^(chl|phy|sphyto|lphyto|diat|nano)','once'))
  name='algae';
elseif ~isempty(regexp(v,'^(no3|po4|si|nh4|fer|dic|talk|don|dop|nut)','once'))
  name='matter';
elseif ~isempty(regexp(v,'^(zoo|szoo|lzoo|det|sdet|ldet|poc|goc|mes)','once'))
  name='turbid';
elseif ~isempty(regexp(v,'^(ak|kv|kt|tke)','once'))
  name='amp';
elseif strcmp(v,'hz')
  name='deep';
else
  name='thermal';
end
return
