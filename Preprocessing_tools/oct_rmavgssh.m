function oct_rmavgssh(bryname,grdname,obc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%  Remove the averaged SSH in the boundary (bry) files.
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%  2D grid variables are (eta,xi) in the file -> (xi,eta) for netcdf.getVar.
%
disp(' ');
disp('Remove averaged SSH ...');
%
% Read the grid and extract the boundary vectors (as row vectors)
%
ng_id = netcdf.open(grdname, 'NC_NOWRITE');
pm_all   =double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'pm'))).';
pn_all   =double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'pn'))).';
mask_all =double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'mask_rho'))).';
netcdf.close(ng_id);
[M,L]=size(pm_all);
%
ncid = netcdf.open(bryname, 'NC_WRITE');
time=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'bry_time')));
tlen=length(time);
suffixes={'_south','_east','_north','_west'};
%
for l=1:tlen
  tssh=0;
  S=0;
  for obcndx=1:4
    if obc(obcndx)==1
      if obcndx==1
        pm=pm_all(1,:);  pn=pn_all(1,:);  rmask=mask_all(1,:);
      elseif obcndx==2
        pm=pm_all(:,L)'; pn=pn_all(:,L)'; rmask=mask_all(:,L)';
      elseif obcndx==3
        pm=pm_all(M,:);  pn=pn_all(M,:);  rmask=mask_all(M,:);
      elseif obcndx==4
        pm=pm_all(:,1)'; pn=pn_all(:,1)'; rmask=mask_all(:,1)';
      end
      Nx=length(pm);
      ssh=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, ['zeta',suffixes{obcndx}]),...
                               [0 l-1],[Nx 1]));
      ssh=ssh(:).';
      tssh=tssh+sum(rmask.*ssh./(pm.*pn));
      S=S+sum(rmask./(pm.*pn)); 
    end
  end
  avgssh=tssh./S;
  for obcndx=1:4
    if obc(obcndx)==1
      if obcndx==1 | obcndx==3
        Nx=L;
      else
        Nx=M;
      end
      vid=netcdf.inqVarID(ncid, ['zeta',suffixes{obcndx}]);
      ssh=double(netcdf.getVar(ncid, vid, [0 l-1], [Nx 1]));
      netcdf.putVar(ncid, vid, [0 l-1], [Nx 1], ssh-avgssh);
    end
  end
end
netcdf.close(ncid);
return
