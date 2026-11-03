function oct_add_ini_bioebus(inifile,clobber)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2014 IRD                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%                                                                 %
%  function nc=add_ini_bioebus(inifile,clobber)                   %
%                                                                 %
%   This function create the header of a Netcdf climatology       %
%   file.                                                         %
%                                                                 %
%   Input:                                                        %
%                                                                 %
%   inifile      Netcdf initial file name (character string).     %
%   clobber      Switch to allow or not writing over an existing  %
%                file.(character string)                          %
%                                                                 %
%   Output                                                        %
%                                                                 %
%   nc       Output netcdf object.                                %
%                                                                 %
%  Gildas Cambon, IRD 2014                                        %
%  Updated    Oct-2026 : Octave version (octave-netcdf, netcdf.* API)
%  Andres Sepulveda 2026 - Octave adaptations
%                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Adding BIOEBUS data in file : ',inifile])
%
%  Open the initial file (old toolbox 'write'/'clobber' modes)
%
if strcmp(clobber,'clobber')
  ncid = netcdf.create(inifile,'NC_CLOBBER');
else
  ncid = netcdf.open(inifile,'NC_WRITE');
  netcdf.reDef(ncid);
end
%
%  Create variables (time,s_rho,eta_rho,xi_rho) -> reversed dim order
%
dims4 = [netcdf.inqDimID(ncid,'xi_rho') netcdf.inqDimID(ncid,'eta_rho') ...
         netcdf.inqDimID(ncid,'s_rho') netcdf.inqDimID(ncid,'time')];
vid_no3 = oct_defvar(ncid,'NO3','double',dims4);
vid_o2  = oct_defvar(ncid,'O2','double',dims4);
%
%  Create attributes
%
netcdf.putAtt(ncid,vid_no3,'long_name','NO3');
netcdf.putAtt(ncid,vid_no3,'units','mMol N m-3');
%
netcdf.putAtt(ncid,vid_o2,'long_name','O2');
netcdf.putAtt(ncid,vid_o2,'units','mMol O m-3');
%
% Leave define mode
%
netcdf.endDef(ncid);

netcdf.close(ncid);
