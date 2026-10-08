function oct_create_bry_Z(zbryname,grdname,title,obc,...
                      Z,time,cycle,clobber,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This function create the header of a Netcdf boundary
%   file (on a z grid).
%
%   Input:
%
%   zbryname     Netcdf climatology file name (character string).
%   grdname      Netcdf grid file name (character string).
%   obc          open boundaries flag (1=open , [S E N W]).
%   Z            Depth of vertical levels.(Vector)
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Creating the file : ',zbryname])
disp(' ')
%
% options for oct_write_time_attributes
insecond = 0;
add_cycle = 1 ; 
%
% Initialize Yorig if not provided
if ~exist('Yorig', 'var') ,  Yorig = [] ; , end
%
% Get time attributes
[time_unit_att,time_second_unit_att,calendar_att]=...
        oct_get_time_attributes(Yorig);
%
%  Read the grid file and check the topography
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
[~,Lp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,Mp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
netcdf.close(ncid);
L=Lp-1;
M=Mp-1;
%
%  Create the boundary file
%
type = 'BOUNDARY Z (or OA) file' ; 
history = 'CROCO' ;
if strcmpi(clobber,'clobber')
  ncid = netcdf.create(zbryname, 'NC_CLOBBER');
else
  ncid = netcdf.create(zbryname, 'NC_NOCLOBBER');
end
%
%  Create dimensions
%
did_xi_u = netcdf.defDim(ncid, 'xi_u', L);
did_xi_rho = netcdf.defDim(ncid, 'xi_rho', Lp);
did_eta_v = netcdf.defDim(ncid, 'eta_v', M);
did_eta_rho = netcdf.defDim(ncid, 'eta_rho', Mp);
did_Z = netcdf.defDim(ncid, 'Z', length(Z));
did_bry_time = netcdf.defDim(ncid, 'bry_time', length(time));
did_one = netcdf.defDim(ncid, 'one', 1);
%
%  Create variables and attributes
%
vid_Z = netcdf.defVar(ncid, 'Z', 'NC_DOUBLE', did_Z);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Z'), 'long_name', 'Depth');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Z'), 'units', 'm');
%
vid_bry_time = netcdf.defVar(ncid, 'bry_time', 'NC_DOUBLE', did_bry_time);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'bry_time'), 'long_name', 'time for temperature climatology');
oct_write_time_attributes(ncid,'bry_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
if obc(1)==1
%
%   Southern boundary
%
  vid_temp_south = netcdf.defVar(ncid, 'temp_south', 'NC_DOUBLE', [did_xi_rho, did_Z, did_bry_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_south'), 'long_name', 'southern boundary potential temperature');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_south'), 'units', 'Celsius');
%
  vid_salt_south = netcdf.defVar(ncid, 'salt_south', 'NC_DOUBLE', [did_xi_rho, did_Z, did_bry_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_south'), 'long_name', 'southern boundary salinity');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_south'), 'units', 'PSU');
%
end
%
if obc(2)==1
%
%   Eastern boundary
%
  vid_temp_east = netcdf.defVar(ncid, 'temp_east', 'NC_DOUBLE', [did_eta_rho, did_Z, did_bry_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_east'), 'long_name', 'eastern boundary potential temperature');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_east'), 'units', 'Celsius');
%
  vid_salt_east = netcdf.defVar(ncid, 'salt_east', 'NC_DOUBLE', [did_eta_rho, did_Z, did_bry_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_east'), 'long_name', 'eastern boundary salinity');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_east'), 'units', 'PSU');
%
end
%
if obc(3)==1
%
%   Northern boundary
%
  vid_temp_north = netcdf.defVar(ncid, 'temp_north', 'NC_DOUBLE', [did_xi_rho, did_Z, did_bry_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_north'), 'long_name', 'northern boundary potential temperature');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_north'), 'units', 'Celsius');
%
  vid_salt_north = netcdf.defVar(ncid, 'salt_north', 'NC_DOUBLE', [did_xi_rho, did_Z, did_bry_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_north'), 'long_name', 'northern boundary salinity');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_north'), 'units', 'PSU');
%
end
%
if obc(4)==1
%
%   Western boundary
%
  vid_temp_west = netcdf.defVar(ncid, 'temp_west', 'NC_DOUBLE', [did_eta_rho, did_Z, did_bry_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_west'), 'long_name', 'western boundary potential temperature');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_west'), 'units', 'Celsius');
%
  vid_salt_west = netcdf.defVar(ncid, 'salt_west', 'NC_DOUBLE', [did_eta_rho, did_Z, did_bry_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_west'), 'long_name', 'western boundary salinity');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_west'), 'units', 'PSU');
%
end
%
%
% Create global attributes
%
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'title', title);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'date', date);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'clim_file', zbryname);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'grd_file', grdname);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'type', type);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'history', history);
%
% Leave define mode
%
netcdf.endDef(ncid);
%
% Write variables
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Z'), Z);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'bry_time'), time);
%
% Initialize the boundary arrays to zero (size from the variable dimensions)
%
bnames={'south','east','north','west'};
for ob=1:4
  if obc(ob)==1
    for vn={'temp','salt'}
      vid=netcdf.inqVarID(ncid,[vn{1},'_',bnames{ob}]);
      [~,~,dids]=netcdf.inqVar(ncid,vid);
      sz=ones(1,max(2,numel(dids)));
      for k=1:numel(dids)
        [~,sz(k)]=netcdf.inqDim(ncid,dids(k));
      end
      netcdf.putVar(ncid,vid,zeros(sz));
    end
  end
end
netcdf.close(ncid);
return


