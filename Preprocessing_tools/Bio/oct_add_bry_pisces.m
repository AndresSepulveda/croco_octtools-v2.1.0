function oct_add_bry_pisces(bryname,obc,time,cycle,...
  makequota,clobber,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function add_bry_pisces(bryname,grdname,title,obc...
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
%  Updated    Oct-2026 : Octave version (octave-netcdf, netcdf.* API)
%  Andres Sepulveda 2026 - Octave adaptations
%                                                                 %
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
disp([' Adding PISCES data into file : ',bryname])
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
tnames = {'dic_time','doc_time','no3_time','po4_time','talk_time','si_time','fer_time','o2_time'};
tlongs = {'time for DIC climatology','time for DOC climatology','time for NO3 climatology','time for PO4 climatology','time for TALK climatology','time for Si climatology','time for FER climatology','time for O2 climatology'};
if makequota
  tnames = [tnames {'dop_time','don_time'}];
  tlongs = [tlongs {'time for DOP climatology','time for DON climatology'}];
end
time=time(:);
for n=1:length(tnames)
  try                                   % already there (second run): reused
    did = netcdf.inqDimID(ncid,tnames{n});
    [~,nt0] = netcdf.inqDim(ncid,did);
    if nt0~=length(time)
      netcdf.close(ncid);
      error(['%s: dimension ',tnames{n},' has %d records in the file, %d now: ',...
             'make the file again (oct_make_bry)'],mfilename,nt0,length(time));
    end
  catch err
    if ~isempty(strfind(err.message,'records in the file')), rethrow(err); end
    did = oct_defdim(ncid,tnames{n},length(time));
  end
  try
    vid = netcdf.inqVarID(ncid,tnames{n});
  catch
    vid = oct_defvar(ncid,tnames{n},'double',did);
  end
  netcdf.putAtt(ncid,vid,'long_name',tlongs{n});
  oct_write_time_attributes(ncid,tnames{n},cycle,time_unit_att,time_second_unit_att,...
    calendar_att,insecond,add_cycle);
end
% nc('one') = 1 : define it only if it does not exist yet
try
  netcdf.inqDimID(ncid,'one');
catch
  oct_defdim(ncid,'one',1);
end
%
%  Boundary variables: (time,s_rho,xi_rho) for S/N, (time,s_rho,eta_rho) for E/W
%
vnames = {'NO3','PO4','Si','O2','DIC','TALK','DOC','FER'};
lnames = {'NO3','PO4','Si','O2','DIC','TALK','DOC','Iron'};
vtimes = {'no3_time','po4_time','si_time','o2_time','dic_time','talk_time','doc_time','fer_time'};
if makequota
  vnames = [vnames {'DOP','DON'}];
  lnames = [lnames {'DOP','DON'}];
  vtimes = [vtimes {'dop_time','don_time'}];
end
suffix = {'_south','_east','_north','_west'};
bname  = {'southern','eastern','northern','western'};
hdim   = {'xi_rho','eta_rho','xi_rho','eta_rho'};
for dn={'s_rho','xi_rho','eta_rho'}       % dimensions of the existing boundary file
  try
    netcdf.inqDimID(ncid,dn{1});
  catch
    netcdf.close(ncid);
    error(['oct_add_bry_pisces: no dimension ',dn{1},' in ',bryname,...
           ': run oct_make_bry first (the PISCES variables are added to its boundary file, mode ''write'')']);
  end
end
did_z  = netcdf.inqDimID(ncid,'s_rho');
for obcndx=1:4
  if obc(obcndx)==1
    did_h = netcdf.inqDimID(ncid,hdim{obcndx});
    for n=1:length(vnames)
      did_t = netcdf.inqDimID(ncid,vtimes{n});
      try                               % already there (second run): reused
        vid = netcdf.inqVarID(ncid,[vnames{n},suffix{obcndx}]);
      catch
        vid = oct_defvar(ncid,[vnames{n},suffix{obcndx}],'double',[did_h did_z did_t]);
      end
      netcdf.putAtt(ncid,vid,'long_name',[bname{obcndx},' boundary ',lnames{n}]);
      netcdf.putAtt(ncid,vid,'units','mMol N m-3');
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
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,tnames{n}),0,length(time),time);
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
