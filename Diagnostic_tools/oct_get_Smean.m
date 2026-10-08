%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get the seasonnal and annual mean.
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
%  Copyright (c) 2005-2006 by Patrick Marchesiello and Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    10-Sep-2006 by Pierrick Penven
%  Updated    24-Oct-2006 by Pierrick Penven (generalisation to all CROCO
%                                             variables)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
%
% Directory and file names
%
directory=[RUN_dir,'SCRATCH/'];
model='croco';
%
% CROCO files
%
infile=[directory,model,'_Mmean.nc'];
outfile=[directory,model,'_Smean.nc'];
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Create the file
%
system([' ',DIAG_dir,'copycdf.csh ',infile,' ',outfile,' "CROCO seasonnal mean file"'])
%
% Initialisation
%
ncid = netcdf.open(infile, 'NC_NOWRITE');
[~,Lm]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,Mm]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
theta_s=ncid.theta_s(:);
rutgers=0;
if (isempty(theta_s))
%  disp('Rutgers version')
  rutgers=1;   
  theta_s=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s'));
  theta_b=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b'));
  Tcline=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Tcline'));
end
[n3dvars,varcell,L,M,N]=oct_get_3dvars(ncid);
netcdf.close(ncid);
%
%
%
disp(['Opening : ',infile])
ncid = netcdf.open(infile, 'NC_NOWRITE');
nw_id = netcdf.open(outfile, 'NC_WRITE');
if rutgers==1
  netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'theta_s'), theta_s);
  netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'theta_b'), theta_b);
  netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'Tcline'), Tcline);
end
%
% loop on the seasons
%
for season=1:5
  disp(['Computing season : ',num2str(season)])
  if season < 5 
    months=[3*season-2:3*season];
  else
    months=(1:12);
  end
  cff=1/(length(months));
  if rutgers==1
    netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'ocean_time'), season-1, 1, cff*sum(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'ocean_time'))));  % [conv] 0-based
  else
    netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'scrum_time'), season-1, 1, cff*sum(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'scrum_time'))));  % [conv] 0-based
  end
  for i=1:n3dvars
    if N(i)==1
      eval(['netcdf.getVar(nw_id, netcdf.inqVarID(nw_id, ''',char(varcell(i)),'''))=cff*sum(nc{''',...
            char(varcell(i)),'''}(months,:,:));'])
    else
      eval(['netcdf.getVar(nw_id, netcdf.inqVarID(nw_id, ''',char(varcell(i)),'''))=cff*sum(nc{''',...
            char(varcell(i)),'''}(months,:,:,:));'])
    
    end
  end
end
netcdf.close(ncid);
netcdf.close(nw_id);

