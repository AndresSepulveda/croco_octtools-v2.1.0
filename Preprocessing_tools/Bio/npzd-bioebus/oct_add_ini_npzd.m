function oct_add_ini_npzd(inifile,clobber)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2014 IRD                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%                                                                 %
%  function nc=oct_add_ini_npzd(inifile,clobber)                      %
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
%   Gildas Cambon, IRD, 20123                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Adding NPZD data in file : ',inifile])
%
%  Create the initial file
%
ncid = netcdf.create(inifile, 'NC_CLOBBER');
%%result = redef(nc);
%
%  Create variables
%
vid_NO3 = netcdf.defVar(ncid, 'NO3', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
vid_O2 = netcdf.defVar(ncid, 'O2', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
%
%  Create attributes
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'long_name', 'NO3');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'units', 'mMol N m-3');
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2'), 'long_name', 'O2');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2'), 'units', 'mMol O m-3');
%
% Leave define mode
%
%%result = endef(nc);
%
% Write variables
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3'), 0);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'O2'), 0);
%
% Synchronize on disk
%
netcdf.close(ncid);
return


