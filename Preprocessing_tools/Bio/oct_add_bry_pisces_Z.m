function oct_add_bry_pisces_Z(zbryname,obc,Z,time,cycle,makequota,...
  clobber,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%   function add_bry_pisces_Z(zbryname,obc,...                    %
%                             Z,time,cycle,clobber);              %
%                                                                 %
%   This function create the header of a Netcdf climatology       %
%   file.                                                         %
%                                                                 %
%   Input:                                                        %
%                                                                 %
%   zbryname     Netcdf climatology file name (character string). %
%   obc          open boundaries flag (1=open , [S E N W]).       %
%   Z            Depth of vertical levels.(Vector)                %
%   time         time.(vector)                                    %
%   cycle        Length (days) for cycling the climatology.(Real) %
%   clobber      Switch to allow or not writing over an existing  %
%                file.(character string)                          %
%                                                                 %
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
disp([' Adding PISCES data into file : ',zbryname])
disp(' ')
%
%  Create the boundary file (old toolbox 'write'/'clobber' modes)
%
if strcmp(clobber,'clobber')
  ncid = netcdf.create(zbryname,'NC_CLOBBER');
else
  ncid = netcdf.open(zbryname,'NC_WRITE');
  netcdf.reDef(ncid);
end
%
%  Create dimensions, time variables and attributes
%
tnames = {'dic_time','doc_time','no3_time','po4_time','talk_time','si_time','fer_time','o2_time'};
tlongs = {'time for DIC','time for DOC','time for NO3','time for PO4','time for TALK','time for silicate','time for iron','time for oxygen'};
if makequota
  tnames = [tnames {'dop_time','don_time'}];
  tlongs = [tlongs {'time for dop','time for don'}];
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
%  Boundary variables: (time,Z,xi_rho) for S/N, (time,Z,eta_rho) for E/W
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
did_z  = netcdf.inqDimID(ncid,'Z');
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
