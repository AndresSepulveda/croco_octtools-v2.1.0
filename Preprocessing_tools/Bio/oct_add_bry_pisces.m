function oct_add_bry_pisces(bryname,obc,time,cycle,...
  makequota,clobber,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function oct_add_bry_pisces(bryname,grdname,title,obc...
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
%                                                                 %
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
%  Redefine the boundary file
%
ncid = netcdf.create(bryname, 'NC_CLOBBER');
%%result = redef(nc);
%
%  Create dimensions
%
did_dic_time = netcdf.defDim(ncid, 'dic_time', length(time));
did_doc_time = netcdf.defDim(ncid, 'doc_time', length(time));
did_no3_time = netcdf.defDim(ncid, 'no3_time', length(time));
did_po4_time = netcdf.defDim(ncid, 'po4_time', length(time));
did_talk_time = netcdf.defDim(ncid, 'talk_time', length(time));
did_si_time = netcdf.defDim(ncid, 'si_time', length(time));
did_fer_time = netcdf.defDim(ncid, 'fer_time', length(time));
did_o2_time = netcdf.defDim(ncid, 'o2_time', length(time));
if makequota
  did_dop_time = netcdf.defDim(ncid, 'dop_time', length(time));
  did_don_time = netcdf.defDim(ncid, 'don_time', length(time));
end
did_one = netcdf.defDim(ncid, 'one', 1);
%
%  Create variables and attributes
%
vid_dic_time = netcdf.defVar(ncid, 'dic_time', 'NC_DOUBLE', did_dic_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dic_time'), 'long_name', 'time for DIC climatology');
oct_write_time_attributes(ncid,'dic_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
vid_talk_time = netcdf.defVar(ncid, 'talk_time', 'NC_DOUBLE', did_talk_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'talk_time'), 'long_name', 'time for TALK climatology');
oct_write_time_attributes(ncid,'talk_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
vid_no3_time = netcdf.defVar(ncid, 'no3_time', 'NC_DOUBLE', did_no3_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'no3_time'), 'long_name', 'time for NO3 climatology');
oct_write_time_attributes(ncid,'no3_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);

%
vid_po4_time = netcdf.defVar(ncid, 'po4_time', 'NC_DOUBLE', did_po4_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'po4_time'), 'long_name', 'time for PO4 climatology');
oct_write_time_attributes(ncid,'po4_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);

%
vid_si_time = netcdf.defVar(ncid, 'si_time', 'NC_DOUBLE', did_si_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'si_time'), 'long_name', 'time for Si climatology');
oct_write_time_attributes(ncid,'si_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);

%
vid_o2_time = netcdf.defVar(ncid, 'o2_time', 'NC_DOUBLE', did_o2_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'o2_time'), 'long_name', 'time for O2 climatology');
oct_write_time_attributes(ncid,'o2_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);

%
vid_doc_time = netcdf.defVar(ncid, 'doc_time', 'NC_DOUBLE', did_doc_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'doc_time'), 'long_name', 'time for DOC climatology');
oct_write_time_attributes(ncid,'doc_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);

%
vid_fer_time = netcdf.defVar(ncid, 'fer_time', 'NC_DOUBLE', did_fer_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'fer_time'), 'long_name', 'time for FER climatology');
oct_write_time_attributes(ncid,'fer_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);

%
if makequota
  vid_dop_time = netcdf.defVar(ncid, 'dop_time', 'NC_DOUBLE', did_dop_time);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dop_time'), 'long_name', 'time for DOP climatology');
  oct_write_time_attributes(ncid,'dop_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
 
  %
  vid_don_time = netcdf.defVar(ncid, 'don_time', 'NC_DOUBLE', did_don_time);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'don_time'), 'long_name', 'time for DON climatology');
  oct_write_time_attributes(ncid,'don_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
  
end
%
%
if obc(1)==1
  %
  %   Southern boundary
  %
  vid_NO3_south = netcdf.defVar(ncid, 'NO3_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_no3_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_south'), 'long_name', 'southern boundary NO3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_south'), 'units', 'mMol N m-3');
  %
  vid_PO4_south = netcdf.defVar(ncid, 'PO4_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_po4_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4_south'), 'long_name', 'southern boundary PO4');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4_south'), 'units', 'mMol N m-3');
  %
  vid_Si_south = netcdf.defVar(ncid, 'Si_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_si_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si_south'), 'long_name', 'southern boundary Si');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si_south'), 'units', 'mMol N m-3');
  %
  vid_O2_south = netcdf.defVar(ncid, 'O2_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_o2_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_south'), 'long_name', 'southern boundary O2');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_south'), 'units', 'mMol N m-3');
  %
  vid_DIC_south = netcdf.defVar(ncid, 'DIC_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_dic_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC_south'), 'long_name', 'southern boundary DIC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC_south'), 'units', 'mMol N m-3');
  %
  vid_TALK_south = netcdf.defVar(ncid, 'TALK_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_talk_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK_south'), 'long_name', 'southern boundary TALK');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK_south'), 'units', 'mMol N m-3');
  %
  vid_DOC_south = netcdf.defVar(ncid, 'DOC_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_doc_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC_south'), 'long_name', 'southern boundary DOC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC_south'), 'units', 'mMol N m-3');
  %
  vid_FER_south = netcdf.defVar(ncid, 'FER_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_fer_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER_south'), 'long_name', 'southern boundary Iron');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER_south'), 'units', 'mMol N m-3');
  %
  if makequota
    vid_DOP_south = netcdf.defVar(ncid, 'DOP_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_dop_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP_south'), 'long_name', 'southern boundary DOP');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP_south'), 'units', 'mMol N m-3');
    %
    vid_DON_south = netcdf.defVar(ncid, 'DON_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_don_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON_south'), 'long_name', 'southern boundary DON');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON_south'), 'units', 'mMol N m-3');
  end
  %
end
%
if obc(2)==1
  %
  %   Eastern boundary
  %
  vid_NO3_east = netcdf.defVar(ncid, 'NO3_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_no3_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_east'), 'long_name', 'eastern boundary NO3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_east'), 'units', 'mMol N m-3');
  %
  vid_PO4_east = netcdf.defVar(ncid, 'PO4_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_po4_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4_east'), 'long_name', 'eastern boundary PO4');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4_east'), 'units', 'mMol N m-3');
  %
  vid_Si_east = netcdf.defVar(ncid, 'Si_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_si_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si_east'), 'long_name', 'eastern boundary Si');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si_east'), 'units', 'mMol N m-3');
  %
  vid_O2_east = netcdf.defVar(ncid, 'O2_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_o2_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_east'), 'long_name', 'eastern boundary O2');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_east'), 'units', 'mMol N m-3');
  %
  vid_DIC_east = netcdf.defVar(ncid, 'DIC_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_dic_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC_east'), 'long_name', 'eastern boundary DIC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC_east'), 'units', 'mMol N m-3');
  %
  vid_TALK_east = netcdf.defVar(ncid, 'TALK_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_talk_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK_east'), 'long_name', 'eastern boundary TALK');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK_east'), 'units', 'mMol N m-3');
  %
  vid_DOC_east = netcdf.defVar(ncid, 'DOC_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_doc_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC_east'), 'long_name', 'eastern boundary DOC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC_east'), 'units', 'mMol N m-3');
  %
  vid_FER_east = netcdf.defVar(ncid, 'FER_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_fer_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER_east'), 'long_name', 'eastern boundary Iron');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER_east'), 'units', 'mMol N m-3');
  %
  if makequota
    vid_DOP_east = netcdf.defVar(ncid, 'DOP_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_dop_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP_east'), 'long_name', 'eastern boundary DOP');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP_east'), 'units', 'mMol N m-3');
    %
    vid_DON_east = netcdf.defVar(ncid, 'DON_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_don_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON_east'), 'long_name', 'eastern boundary DON');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON_east'), 'units', 'mMol N m-3');
  end
  %
end
%
if obc(3)==1
  %
  %   Northern boundary
  %
  vid_NO3_north = netcdf.defVar(ncid, 'NO3_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_no3_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_north'), 'long_name', 'northern boundary NO3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_north'), 'units', 'mMol N m-3');
  %
  vid_PO4_north = netcdf.defVar(ncid, 'PO4_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_po4_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4_north'), 'long_name', 'northern boundary PO4');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4_north'), 'units', 'mMol N m-3');
  %
  vid_Si_north = netcdf.defVar(ncid, 'Si_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_si_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si_north'), 'long_name', 'northern boundary Si');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si_north'), 'units', 'mMol N m-3');
  %
  vid_O2_north = netcdf.defVar(ncid, 'O2_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_o2_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_north'), 'long_name', 'northern boundary O2');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_north'), 'units', 'mMol N m-3');
  %
  vid_DIC_north = netcdf.defVar(ncid, 'DIC_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_dic_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC_north'), 'long_name', 'northern boundary DIC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC_north'), 'units', 'mMol N m-3');
  %
  vid_TALK_north = netcdf.defVar(ncid, 'TALK_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_talk_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK_north'), 'long_name', 'northern boundary TALK');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK_north'), 'units', 'mMol N m-3');
  %
  vid_DOC_north = netcdf.defVar(ncid, 'DOC_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_doc_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC_north'), 'long_name', 'northern boundary DOC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC_north'), 'units', 'mMol N m-3');
  %
  vid_FER_north = netcdf.defVar(ncid, 'FER_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_fer_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER_north'), 'long_name', 'northern boundary Iron');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER_north'), 'units', 'mMol N m-3');
  %
  if makequota
    vid_DOP_north = netcdf.defVar(ncid, 'DOP_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_dop_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP_north'), 'long_name', 'northern boundary DOP');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP_north'), 'units', 'mMol N m-3');
    %
    vid_DON_north = netcdf.defVar(ncid, 'DON_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_don_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON_north'), 'long_name', 'northern boundary DON');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON_north'), 'units', 'mMol N m-3');
  end
  %
end
%
if obc(4)==1
  %
  %   Western boundary
  %
  vid_NO3_west = netcdf.defVar(ncid, 'NO3_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_no3_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_west'), 'long_name', 'western boundary NO3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3_west'), 'units', 'mMol N m-3');
  %
  vid_PO4_west = netcdf.defVar(ncid, 'PO4_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_po4_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4_west'), 'long_name', 'western boundary PO4');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4_west'), 'units', 'mMol N m-3');
  %
  vid_Si_west = netcdf.defVar(ncid, 'Si_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_si_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si_west'), 'long_name', 'western boundary Si');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si_west'), 'units', 'mMol N m-3');
  %
  vid_O2_west = netcdf.defVar(ncid, 'O2_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_o2_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_west'), 'long_name', 'western boundary O2');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2_west'), 'units', 'mMol N m-3');
  %
  vid_DIC_west = netcdf.defVar(ncid, 'DIC_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_dic_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC_west'), 'long_name', 'western boundary DIC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC_west'), 'units', 'mMol N m-3');
  %
  vid_TALK_west = netcdf.defVar(ncid, 'TALK_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_talk_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK_west'), 'long_name', 'western boundary TALK');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK_west'), 'units', 'mMol N m-3');
  %
  vid_DOC_west = netcdf.defVar(ncid, 'DOC_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_doc_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC_west'), 'long_name', 'western boundary DOC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC_west'), 'units', 'mMol N m-3');
  %
  vid_FER_west = netcdf.defVar(ncid, 'FER_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_fer_time]);
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER_west'), 'long_name', 'western boundary Iron');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER_west'), 'units', 'mMol N m-3');
  %
  if makequota
    vid_DOP_west = netcdf.defVar(ncid, 'DOP_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_dop_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP_west'), 'long_name', 'western boundary DOP');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP_west'), 'units', 'mMol N m-3');
    %
    vid_DON_west = netcdf.defVar(ncid, 'DON_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_don_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON_west'), 'long_name', 'western boundary DON');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON_west'), 'units', 'mMol N m-3');
  end
  %
end
%
% Leave define mode
%
%%result = endef(nc);
%
% Write variables
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dic_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'doc_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'no3_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'po4_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'talk_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'si_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'fer_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'o2_time'), time);
if makequota
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dop_time'), time);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'don_time'), time);
end
if obc(1)==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'PO4_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Si_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'O2_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DIC_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'TALK_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DOC_south'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'FER_south'), 0);
  if makequota
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DOP_south'), 0);
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DON_south'), 0);
  end
end
if obc(2)==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'PO4_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Si_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'O2_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DIC_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'TALK_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DOC_east'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'FER_east'), 0);
  if makequota
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DOP_east'), 0);
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DON_east'), 0);
  end
end
if obc(3)==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'PO4_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Si_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'O2_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DIC_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'TALK_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DOC_north'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'FER_north'), 0);
  if makequota
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DOP_north'), 0);
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DON_north'), 0);
  end
end
if obc(4)==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'PO4_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Si_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'O2_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DIC_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'TALK_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DOC_west'), 0);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'FER_west'), 0);
  if makequota
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DOP_west'), 0);
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DON_west'), 0);
  end
end
netcdf.close(ncid);
return

