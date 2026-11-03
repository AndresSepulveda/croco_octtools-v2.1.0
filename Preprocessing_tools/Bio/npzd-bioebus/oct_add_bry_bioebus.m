function oct_add_bry_bioebus(bryname,obc,time_no3,time_o2,time_zoo,time_phyto,time_chla,cycle,clobber);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 
% function add_bry_bioebus(bryname,grdname,title,obc...            
%                         theta_s,theta_b,hc,N,...                
%                         time,cycle,clobber);                    
%                                                                 
%   This function create the header of a Netcdf climatology       
%   file.                                                         
%                                                                 
%   Input:                                                        
%                                                                 
%   bryname      Netcdf climatology file name (character string). 
%   obc          open boundaries flag (1=open , [S E N W]).       
%   time         time.(vector)                                    
%   cycle        Length (days) for cycling the climatology.(Real) 
%   clobber      Switch to allow or not writing over an existing  
%                file.(character string)                          
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
%  Pierrick Penven, IRD, 2005.                                    %
%  Olivier Aumont the master, IRD, 2006.                          %
%  Patricio Marchesiello, chief, IRD, 2007.                       %
%  Christophe Eugene Raoul Menkes, the slave, IRD, 2007.          %
%  Gildas Cambon, IRD, 2011                                       %
%  Gildas Cambon, IRD, 2013 : Add oxygen processing               %
%  Updated    Oct-2026 : Octave version (octave-netcdf, netcdf.* API)
%  Andres Sepulveda 2026 - Octave adaptations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% options for write_time_attributes
%
% options for oct_write_time_attributes
insecond =  0 ;
add_cycle = 1 ; 
%
% Initialize Yorig if not provided
if ~exist('Yorig', 'var') ,  Yorig = []; , end
%
% Get time attributes
[time_unit_att,time_second_unit_att,calendar_att]=...
    oct_get_time_attributes(Yorig);
%
disp(' ')
disp([' Adding BIOEBUS BGC data into file : ',bryname])
disp(' ')
%
%  Redefine the boundary file (old toolbox 'write'/'clobber' modes)
%
if strcmp(clobber,'clobber')
  ncid = netcdf.create(bryname,'NC_CLOBBER');
else
  ncid = netcdf.open(bryname,'NC_WRITE');
  netcdf.reDef(ncid);
end
%
%  Create dimensions, time variables and attributes
%
tnames = {'no3_time','o2_time','chla_time','sphyto_time','lphyto_time','szoo_time','lzoo_time'};
tvals  = {time_no3,time_o2,time_chla,time_phyto,time_phyto,time_zoo,time_zoo};
tlongs = {'time for NO3 climatology','time for O2 climatology','time for CHLA climatology','time for SPHYTO climatology','time for LPHYTO climatology','time for SZOO climatology','time for LZOO climatology'};
for n=1:length(tnames)
  did = oct_defdim(ncid,tnames{n},length(tvals{n}));
end
% nc('one') = 1 : define it only if it does not exist yet
try
  netcdf.inqDimID(ncid,'one');
catch
  oct_defdim(ncid,'one',1);
end
for n=1:length(tnames)
  vid = oct_defvar(ncid,tnames{n},'double',netcdf.inqDimID(ncid,tnames{n}));
  netcdf.putAtt(ncid,vid,'long_name',tlongs{n});
  oct_write_time_attributes(ncid,tnames{n},cycle,time_unit_att,time_second_unit_att,...
    calendar_att,insecond,add_cycle);
end
%
%  Boundary variables: (time,s_rho,xi_rho) for S/N, (time,s_rho,eta_rho) for E/W
%
vnames = {'NO3','O2','CHLA','SPHYTO','LPHYTO','SZOO','LZOO'};
vtimes = {'no3_time','o2_time','chla_time','sphyto_time','lphyto_time','szoo_time','lzoo_time'};
vunits = {'mMol N m-3','mMol N m-3','mMol N m-3','mMol N m-3','mMol N m-3','mMol N m-3','mMol N m-3'};
suffix = {'_south','_east','_north','_west'};
bname  = {'southern','eastern','northern','western'};
hdim   = {'xi_rho','eta_rho','xi_rho','eta_rho'};
did_z  = netcdf.inqDimID(ncid,'s_rho');
for obcndx=1:4
  if obc(obcndx)==1
    disp(['Process ',upper(bname{obcndx}(1)),bname{obcndx}(2:end),' boundary'])
    did_h = netcdf.inqDimID(ncid,hdim{obcndx});
    for n=1:length(vnames)
      vt = vtimes{n};
      did_t = netcdf.inqDimID(ncid,vt);
      vid = oct_defvar(ncid,[vnames{n},suffix{obcndx}],'double',[did_h did_z did_t]);
      netcdf.putAtt(ncid,vid,'long_name',[bname{obcndx},' boundary ',vnames{n}]);
      netcdf.putAtt(ncid,vid,'units',vunits{n});
    end
  end
end
%
% Leave define mode
%
netcdf.endDef(ncid);
%
% Write variables
%
for n=1:length(tnames)
  tv=tvals{n};
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,tnames{n}),0,length(tv),tv(:));
end
for obcndx=1:4
  if obc(obcndx)==1
    for n=1:length(vnames)
      % nc{'X'}(:) = 0 : fill the whole variable with 0
      vid = netcdf.inqVarID(ncid,[vnames{n},suffix{obcndx}]);
      [~,~,dimids] = netcdf.inqVar(ncid,vid);
      cnt = zeros(1,length(dimids));
      for d=1:length(dimids)
        [~,cnt(d)] = netcdf.inqDim(ncid,dimids(d));
      end
      netcdf.putVar(ncid,vid,zeros(1,length(cnt)),cnt,zeros(cnt));
    end
  end
end
netcdf.close(ncid);
return
