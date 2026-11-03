function oct_add_ini_pisces(inifile,clobber,makequota)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 IRD                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%                                                                 %
%  function nc=add_ini_pisces(inifile,clobber)                    %
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
%  Updated    Oct-2026 : Octave version (octave-netcdf, netcdf.* API)
%  Andres Sepulveda 2026 - Octave adaptations
%                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Adding PISCES data in file : ',inifile])
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
%  Create variables (netcdf.defVar: dims in reversed order)
%
did_xi  = netcdf.inqDimID(ncid,'xi_rho');
did_eta = netcdf.inqDimID(ncid,'eta_rho');
did_s   = netcdf.inqDimID(ncid,'s_rho');
did_t   = netcdf.inqDimID(ncid,'time');
dims4   = [did_xi did_eta did_s did_t];
vnames = {'NO3','PO4','Si','O2','DIC','TALK','DOC','FER'};
lnames = {'NO3','PO4','Si','O2','DIC','TALK','DOC','FER'};
units  = {'mMol N m-3','mMol P m-3','mMol Si m-3','mMol O m-3',...
          'mMol C m-3','mMol C m-3','mMol C m-3','mMol Fe m-3'};
if makequota
  vnames = [vnames {'DON','DOP'}];
  lnames = [lnames {'DON','DOP'}];
  units  = [units {'mMol C m-3','mMol C m-3'}];
end
for n=1:length(vnames)
  vid = netcdf.defVar(ncid,vnames{n},'double',dims4);
%
%  Create attributes
%
  netcdf.putAtt(ncid,vid,'long_name',lnames{n});
  netcdf.putAtt(ncid,vid,'units',units{n});
end
%
% Leave define mode
%
netcdf.endDef(ncid);
%
% Write variables (nc{'X'}(:)=0 : fill the whole variable with 0)
%
for n=1:length(vnames)
  vid = netcdf.inqVarID(ncid,vnames{n});
  [~,~,dimids] = netcdf.inqVar(ncid,vid);
  cnt = zeros(1,length(dimids));
  for d=1:length(dimids)
    [~,cnt(d)] = netcdf.inqDim(ncid,dimids(d));
  end
  netcdf.putVar(ncid,vid,zeros(1,length(cnt)),cnt,zeros(cnt));
end
%
% Synchronize on disk
%
netcdf.close(ncid);
return
