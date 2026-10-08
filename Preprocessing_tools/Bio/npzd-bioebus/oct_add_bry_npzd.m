function oct_add_bry_npzd(bryname,obc,time_no3,time_o2,time_zoo,time_phyto,time_chla,cycle,clobber);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 
% function add_bry_bgc(bryname,grdname,title,obc...            
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
disp([' Adding PISCES data into file : ',bryname])
disp(' ')
%
disp(' ')
disp([' Adding NPZD BGC data into file : ',bryname])
disp(' ')
%
%  Redefine the boundary file
%
ncid = netcdf.create(bryname, 'NC_CLOBBER');
%%result = redef(nc);
%
%  Create dimensions
%
did_no3_time = netcdf.defDim(ncid, 'no3_time', length(time_no3));
did_o2_time = netcdf.defDim(ncid, 'o2_time', length(time_o2));
did_chla_time = netcdf.defDim(ncid, 'chla_time', length(time_chla));
did_phyto_time = netcdf.defDim(ncid, 'phyto_time', length(time_phyto));
did_zoo_time = netcdf.defDim(ncid, 'zoo_time', length(time_zoo));
did_one = netcdf.defDim(ncid, 'one', 1);
%
%  Create variables and attributes
%
vid_no3_time = netcdf.defVar(ncid, 'no3_time', 'NC_DOUBLE', did_no3_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'no3_time'), 'long_name', 'time for NO3 climatology');
oct_write_time_attributes(ncid,'no3_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
vid_o2_time = netcdf.defVar(ncid, 'o2_time', 'NC_DOUBLE', did_o2_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'o2_time'), 'long_name', 'time for O2 climatology');
oct_write_time_attributes(ncid,'o2_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
vid_chla_time = netcdf.defVar(ncid, 'chla_time', 'NC_DOUBLE', did_chla_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'chla_time'), 'long_name', 'time for CHLA climatology');
oct_write_time_attributes(ncid,'chla_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
vid_phyto_time = netcdf.defVar(ncid, 'phyto_time', 'NC_DOUBLE', did_phyto_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'phyto_time'), 'long_name', 'time for PHYTO climatology');
oct_write_time_attributes(ncid,'phyto_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
vid_zoo_time = netcdf.defVar(ncid, 'zoo_time', 'NC_DOUBLE', did_zoo_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zoo_time'), 'long_name', 'time for ZOO climatology');
oct_write_time_attributes(ncid,'zoo_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
%
if obc(1)==1
%
%   Southern boundary
%
  disp('Process Southern boundary')
  
  vid_NO3_south = netcdf.defVar(ncid, 'NO3_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_no3_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_south'), 'long_name', 'southern boundary NO3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_south'), 'units', 'mMol N m-3');
%
  vid_O2_south = netcdf.defVar(ncid, 'O2_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_o2_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_south'), 'long_name', 'southern boundary O2');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_south'), 'units', 'mMol N m-3');
  %
  vid_CHLA_south = netcdf.defVar(ncid, 'CHLA_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_chla_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA_south'), 'long_name', 'southern boundary CHLA');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA_south'), 'units', 'mMol N m-3');
%
  vid_PHYTO_south = netcdf.defVar(ncid, 'PHYTO_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_phyto_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PHYTO_south'), 'long_name', 'southern boundary PHYTO');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PHYTO_south'), 'units', 'mMol N m-3');
%
  vid_ZOO_south = netcdf.defVar(ncid, 'ZOO_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_zoo_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO_south'), 'long_name', 'southern boundary ZOO');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO_south'), 'units', 'mMol N m-3');
%
end
%
if obc(2)==1
%
%   Eastern boundary
%
  disp('Process Esater boundary')
  
  vid_NO3_east = netcdf.defVar(ncid, 'NO3_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_no3_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_east'), 'long_name', 'eastern boundary NO3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_east'), 'units', 'mMol N m-3');
%
  vid_O2_east = netcdf.defVar(ncid, 'O2_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_o2_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_east'), 'long_name', 'eastern boundary O2');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_east'), 'units', 'mMol N m-3');
  %
  vid_CHLA_east = netcdf.defVar(ncid, 'CHLA_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_chla_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA_east'), 'long_name', 'eastern boundary CHLA');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA_east'), 'units', 'mMol N m-3');
%
  vid_ZOO_east = netcdf.defVar(ncid, 'ZOO_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_zoo_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO_east'), 'long_name', 'eastern boundary ZOO');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO_east'), 'units', 'mMol N m-3');
%
  vid_PHYTO_east = netcdf.defVar(ncid, 'PHYTO_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_phyto_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PHYTO_east'), 'long_name', 'eastern boundary PHYTO');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PHYTO_east'), 'units', 'mMol N m-3');
%
end
%
if obc(3)==1
%
%   Northern boundary
%
  disp('Process Northern boundary')
  
  vid_NO3_north = netcdf.defVar(ncid, 'NO3_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_no3_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_north'), 'long_name', 'northern boundary NO3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_north'), 'units', 'mMol N m-3');
%
  vid_O2_north = netcdf.defVar(ncid, 'O2_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_o2_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_north'), 'long_name', 'northern boundary O2');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_north'), 'units', 'mMol N m-3');
%
  vid_CHLA_north = netcdf.defVar(ncid, 'CHLA_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_chla_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA_north'), 'long_name', 'northern boundary CHLA');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA_north'), 'units', 'mMol N m-3');
%
  vid_ZOO_north = netcdf.defVar(ncid, 'ZOO_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_zoo_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO_north'), 'long_name', 'northern boundary ZOO');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO_north'), 'units', 'mMol N m-3');
%
  vid_PHYTO_north = netcdf.defVar(ncid, 'PHYTO_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_phyto_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PHYTO_north'), 'long_name', 'northern boundary PHYTO');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PHYTO_north'), 'units', 'mMol N m-3');
%
end
%
if obc(4)==1
%
%   Western boundary
%
   disp('Process Western boundary')
 
  vid_NO3_west = netcdf.defVar(ncid, 'NO3_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_no3_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_west'), 'long_name', 'western boundary NO3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_west'), 'units', 'mMol N m-3');
%
  vid_O2_west = netcdf.defVar(ncid, 'O2_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_o2_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_west'), 'long_name', 'western boundary O2');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_west'), 'units', 'mMol N m-3');
%
  vid_CHLA_west = netcdf.defVar(ncid, 'CHLA_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_chla_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA_west'), 'long_name', 'western boundary CHLA');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA_west'), 'units', 'mMol N m-3');
%
  vid_PHYTO_west = netcdf.defVar(ncid, 'PHYTO_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_phyto_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PHYTO_west'), 'long_name', 'western boundary PHYTO');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PHYTO_west'), 'units', 'mMol N m-3');
%
  vid_ZOO_west = netcdf.defVar(ncid, 'ZOO_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_zoo_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO_west'), 'long_name', 'western boundary ZOO');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO_west'), 'units', 'mMol N m-3');
%
end
%
% Leave define mode
%
%%result = endef(nc);
%
% Write variables
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'zoo_time'), time_zoo);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'phyto_time'), time_phyto);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'no3_time'), time_no3);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'o2_time'), time_o2);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'chla_time'), time_chla);
if obc(1)==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'O2_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'CHLA_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'PHYTO_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ZOO_south'), 0);
end 
if obc(2)==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'O2_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'CHLA_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'PHYTO_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ZOO_east'), 0);
end 
if obc(3)==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'O2_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'CHLA_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'PHYTO_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ZOO_north'), 0);
end 
if obc(4)==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'O2_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'CHLA_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'PHYTO_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ZOO_west'), 0);
end 
netcdf.close(ncid);
return

