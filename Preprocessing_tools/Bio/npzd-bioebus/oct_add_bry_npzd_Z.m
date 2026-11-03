function oct_add_bry_npzd_Z(zbryname,obc,Z,time_no3,time_o2,time_zoo,time_phyto,time_chla,cycle,clobber);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%   function add_bry_npzd_Z(zbryname,obc,...                    %
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
%  Gildas Cambon, IRD/LEGOS, 2013 : Add O2 processing             %
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
disp([' Adding NPZ BGC data into file : ',zbryname])
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
tnames = {'no3_time','o2_time','chla_time','phyto_time','zoo_time'};
tvals  = {time_no3,time_no3,time_chla,time_phyto,time_zoo};
tlongs = {'time for NO3 climatology','time for O2 climatology','time for CHLA climatology','time for PHYTO climatology','time for ZOO climatology'};
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
%  Boundary variables: (time,Z,xi_rho) for S/N, (time,Z,eta_rho) for E/W
%
vnames = {'NO3','O2','CHLA','PHYTO','ZOO'};
vtimes = {'no3_time','o2_time','chla_time','phyto_time','zoo_time'};
vunits = {'mMol N m-3','mMol O m-3','mMol N m-3','mMol N m-3','mMol N m-3'};
suffix = {'_south','_east','_north','_west'};
bname  = {'southern','eastern','northern','western'};
hdim   = {'xi_rho','eta_rho','xi_rho','eta_rho'};
did_z  = netcdf.inqDimID(ncid,'Z');
for obcndx=1:4
  if obc(obcndx)==1
    disp(['Process ',upper(bname{obcndx}(1)),bname{obcndx}(2:end),' boundary'])
    did_h = netcdf.inqDimID(ncid,hdim{obcndx});
    for n=1:length(vnames)
      vt = vtimes{n};
      if obcndx==4 && strcmp(vnames{n},'O2'), vt='no3_time'; end  % as in the Matlab version
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
