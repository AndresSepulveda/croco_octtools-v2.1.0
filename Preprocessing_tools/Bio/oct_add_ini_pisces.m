function oct_add_ini_pisces(inifile,clobber,makequota)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 IRD                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%                                                                 %
%  function nc=oct_add_ini_pisces(inifile,clobber)                    %
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
%   Pierrick Penven, IRD, 2005.                                   %
%   Olivier Aumont, IRD, 2006.                                    %
%   Patricio Marchesiello, IRD 2007                               %
%   Christophe Eugene Raoul Menkes, IRD 2007                      %
%                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Adding PISCES data in file : ',inifile])
%
%  Create the initial file
%
ncid = netcdf.create(inifile, 'NC_CLOBBER');
%%result = redef(nc);
%
%  Create variables
%
vid_NO3 = netcdf.defVar(ncid, 'NO3', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
vid_PO4 = netcdf.defVar(ncid, 'PO4', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
vid_Si = netcdf.defVar(ncid, 'Si', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
vid_O2 = netcdf.defVar(ncid, 'O2', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
vid_DIC = netcdf.defVar(ncid, 'DIC', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
vid_TALK = netcdf.defVar(ncid, 'TALK', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
vid_DOC = netcdf.defVar(ncid, 'DOC', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
vid_FER = netcdf.defVar(ncid, 'FER', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
if makequota
   vid_DON = netcdf.defVar(ncid, 'DON', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
   vid_DOP = netcdf.defVar(ncid, 'DOP', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
end

%
%  Create attributes
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'long_name', 'NO3');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'units', 'mMol N m-3');
%
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4'), 'long_name', 'PO4');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4'), 'units', 'mMol P m-3');
%
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si'), 'long_name', 'Si');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si'), 'units', 'mMol Si m-3');
%
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2'), 'long_name', 'O2');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2'), 'units', 'mMol O m-3');
%
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC'), 'long_name', 'DIC');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC'), 'units', 'mMol C m-3');
%
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK'), 'long_name', 'TALK');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK'), 'units', 'mMol C m-3');
%
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC'), 'long_name', 'DOC');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC'), 'units', 'mMol C m-3');
%
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER'), 'long_name', 'FER');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER'), 'units', 'mMol Fe m-3');
%
%
if makequota
   % [conv] línea ncchar duplicada omitida
   netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON'), 'long_name', 'DON');
   % [conv] línea ncchar duplicada omitida
   netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON'), 'units', 'mMol C m-3');
%
%
   % [conv] línea ncchar duplicada omitida
   netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP'), 'long_name', 'DOP');
   % [conv] línea ncchar duplicada omitida
   netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP'), 'units', 'mMol C m-3');
end
%
% Leave define mode
%
%%result = endef(nc);
%
% Write variables
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3'), 0);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'PO4'), 0);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Si'), 0);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'O2'), 0);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DIC'), 0);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'TALK'), 0);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DOC'), 0);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'FER'), 0);
if makequota
   netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DON'), 0);
   netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'DOP'), 0);
end
%
% Synchronize on disk
%
netcdf.close(ncid);
return


