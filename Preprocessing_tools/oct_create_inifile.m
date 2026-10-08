function oct_create_inifile(inifile,gridfile,title,...
                        theta_s,theta_b,hc,N,time,clobber,vtransform,...
                        Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function nc=oct_create_inifile(inifile,gridfile,theta_s,...
%                  theta_b,hc,N,ttime,stime,utime,... 
%                  cycle,clobber)
%
%   This function create the header of a Netcdf climatology 
%   file.
%
%   Input: 
% 
%   inifile      Netcdf initial file name (character string).
%   gridfile     Netcdf grid file name (character string).
%   theta_s      S-coordinate surface control parameter.(Real)
%   theta_b      S-coordinate bottom control parameter.(Real)
%   hc           Width (m) of surface or bottom boundary layer
%                where higher vertical resolution is required 
%                during stretching.(Real)
%   N            Number of vertical levels.(Integer)  
%   time         Initial time.(Real) 
%   clobber      Switch to allow or not writing over an existing
%                file.(character string) 
%
%   Output
%
%   nc       Output netcdf object.
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Creating the file : ',inifile])

if nargin < 10
   disp([' NO VTRANSFORM parameter found'])
   disp([' USE TRANSFORM default value vtransform = 1'])
   vtransform = 1; 
   disp([' VTRANSFORM = ',num2str(vtransform)])
end
%
% options for oct_write_time_attributes
insecond = 1  ;
add_cycle = 0 ; 
%
% Initialize Yorig if not provided
if ~exist('Yorig', 'var') ,  Yorig = []; , end
%
% Get time attributes
[time_unit_att,time_second_unit_att,calendar_att]=...
    oct_get_time_attributes(Yorig);
%
%  Read the grid file
%
ncid = netcdf.open(gridfile, 'NC_NOWRITE');
h=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'))).';  
mask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'))).';
netcdf.close(ncid);
hmin=min(min(h(mask==1)));
if vtransform ==1;
    if hc > hmin
        error([' hc (',num2str(hc),' m) > hmin (',num2str(hmin),' m)'])
    end
end
[Mp,Lp]=size(h);
L=Lp-1;
M=Mp-1;
Np=N+1;
%
%  Create the initial file
%
type = 'INITIAL file' ; 
history = 'CROCO' ;
if strcmpi(clobber,'clobber')
  ncid = netcdf.create(inifile, 'NC_CLOBBER');
else
  ncid = netcdf.create(inifile, 'NC_NOCLOBBER');
end
%
%  Create dimensions
%
did_xi_u = netcdf.defDim(ncid, 'xi_u', L);
did_xi_v = netcdf.defDim(ncid, 'xi_v', Lp);
did_xi_rho = netcdf.defDim(ncid, 'xi_rho', Lp);
did_eta_u = netcdf.defDim(ncid, 'eta_u', Mp);
did_eta_v = netcdf.defDim(ncid, 'eta_v', M);
did_eta_rho = netcdf.defDim(ncid, 'eta_rho', Mp);
did_s_rho = netcdf.defDim(ncid, 's_rho', N);
did_s_w = netcdf.defDim(ncid, 's_w', Np);
did_tracer = netcdf.defDim(ncid, 'tracer', 2);
did_time = netcdf.defDim(ncid, 'time', netcdf.getConstant('NC_UNLIMITED'));
did_one = netcdf.defDim(ncid, 'one', 1);
%
%  Create variables
%
vid_spherical = netcdf.defVar(ncid, 'spherical', 'NC_CHAR', did_one);
vid_Vtransform = netcdf.defVar(ncid, 'Vtransform', 'NC_INT', did_one);
vid_Vstretching = netcdf.defVar(ncid, 'Vstretching', 'NC_INT', did_one);
vid_tstart = netcdf.defVar(ncid, 'tstart', 'NC_DOUBLE', did_one);
vid_tend = netcdf.defVar(ncid, 'tend', 'NC_DOUBLE', did_one);
vid_theta_s = netcdf.defVar(ncid, 'theta_s', 'NC_DOUBLE', did_one);
vid_theta_b = netcdf.defVar(ncid, 'theta_b', 'NC_DOUBLE', did_one);
vid_Tcline = netcdf.defVar(ncid, 'Tcline', 'NC_DOUBLE', did_one);
vid_hc = netcdf.defVar(ncid, 'hc', 'NC_DOUBLE', did_one);
vid_s_rho = netcdf.defVar(ncid, 's_rho', 'NC_DOUBLE', did_s_rho);
vid_Cs_rho = netcdf.defVar(ncid, 'Cs_rho', 'NC_DOUBLE', did_s_rho);
vid_ocean_time = netcdf.defVar(ncid, 'ocean_time', 'NC_DOUBLE', did_time);
vid_scrum_time = netcdf.defVar(ncid, 'scrum_time', 'NC_DOUBLE', did_time);
vid_u = netcdf.defVar(ncid, 'u', 'NC_DOUBLE', [did_xi_u, did_eta_u, did_s_rho, did_time]);
vid_v = netcdf.defVar(ncid, 'v', 'NC_DOUBLE', [did_xi_v, did_eta_v, did_s_rho, did_time]);
vid_ubar = netcdf.defVar(ncid, 'ubar', 'NC_DOUBLE', [did_xi_u, did_eta_u, did_time]);
vid_vbar = netcdf.defVar(ncid, 'vbar', 'NC_DOUBLE', [did_xi_v, did_eta_v, did_time]);
vid_zeta = netcdf.defVar(ncid, 'zeta', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_time]);
vid_temp = netcdf.defVar(ncid, 'temp', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
vid_salt = netcdf.defVar(ncid, 'salt', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
%
%  Create attributes
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Vtransform'), 'long_name', 'vertical terrain-following transformation equation');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Vstretching'), 'long_name', 'vertical terrain-following stretching function');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'tstart'), 'long_name', 'start processing day');
oct_write_time_attributes(ncid,'tstart','',time_unit_att,time_second_unit_att,...
                      calendar_att,0,0);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'tend'), 'long_name', 'end processing day');
oct_write_time_attributes(ncid,'tend','',time_unit_att,time_second_unit_att,...
                      calendar_att,0,0);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'theta_s'), 'long_name', 'S-coordinate surface control parameter');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'theta_s'), 'units', 'nondimensional');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'theta_b'), 'long_name', 'S-coordinate bottom control parameter');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'theta_b'), 'units', 'nondimensional');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Tcline'), 'long_name', 'S-coordinate surface/bottom layer width');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Tcline'), 'units', 'meter');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'hc'), 'long_name', 'S-coordinate parameter, critical depth');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'hc'), 'units', 'meter');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'long_name', 'S-coordinate at RHO-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'units', 'nondimensional');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'valid_min', -1);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'valid_max', 0);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), 'long_name', 'S-coordinate stretching curves at RHO-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), 'units', 'nondimensional');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), 'valid_min', -1);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), 'valid_max', 0);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ocean_time'), 'long_name', 'time since initialization');
oct_write_time_attributes(ncid,'ocean_time','',time_unit_att,time_second_unit_att,...
                      calendar_att,1,0);

netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'scrum_time'), 'long_name', 'time since initialization');
oct_write_time_attributes(ncid,'scrum_time','',time_unit_att,time_second_unit_att,...
                      calendar_att,1,0);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u'), 'long_name', 'u-momentum component');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u'), 'units', 'meter second-1');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v'), 'long_name', 'v-momentum component');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v'), 'units', 'meter second-1');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar'), 'long_name', 'vertically integrated u-momentum component');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar'), 'units', 'meter second-1');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar'), 'long_name', 'vertically integrated v-momentum component');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar'), 'units', 'meter second-1');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta'), 'long_name', 'free-surface');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta'), 'units', 'meter');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp'), 'long_name', 'potential temperature');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp'), 'units', 'Celsius');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt'), 'long_name', 'salinity');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt'), 'units', 'PSU');
%
% Create global attributes
%
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'title', title);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'date', date);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'clim_file', inifile);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'grd_file', gridfile);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'type', type);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'history', history);
%
% Leave define mode
%
netcdf.endDef(ncid);
%
% Compute S coordinates
%
[s_rho,Cs_rho,s_w,Cs_w] = oct_scoordinate(theta_s,theta_b,N,hc,vtransform);
%disp(['vtransform=',num2str(vtransform)])
%
% Write variables
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'spherical'), 'T');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Vtransform'), int32(vtransform));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Vstretching'), int32(1));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'tstart'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'tend'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'theta_s'), theta_s);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'theta_b'), theta_b);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Tcline'), hc);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'hc'), hc);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 's_rho'), s_rho);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), Cs_rho);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'scrum_time'), 0, 1, time*24*3600);   % record 1 (0-based start)
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ocean_time'), 0, 1, time*24*3600);   % record 1 (0-based start)
%
% Initialize record 1 to zero (unlimited time dimension: explicit start/count,
% Fortran order xi,eta,s,time)
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'u'),    [0 0 0 0], [L Mp N 1],  zeros(L,Mp,N));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'v'),    [0 0 0 0], [Lp M N 1],  zeros(Lp,M,N));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'zeta'), [0 0 0],   [Lp Mp 1],   zeros(Lp,Mp));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ubar'), [0 0 0],   [L Mp 1],    zeros(L,Mp));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'vbar'), [0 0 0],   [Lp M 1],    zeros(Lp,M));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'temp'), [0 0 0 0], [Lp Mp N 1], zeros(Lp,Mp,N));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'salt'), [0 0 0 0], [Lp Mp N 1], zeros(Lp,Mp,N));
%
% Synchronize on disk
%
netcdf.close(ncid);
return


