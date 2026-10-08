function oct_plot_tide(grdname,frcname,k,cff,skp,coastfileplot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Plot tidal ellipses 
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
%  Copyright (c) 2003-2006 by Patrick Marchesiello
%
%  Updated   5-Oct-2006 by Pierrick Penven
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rad=pi/180.0;
deg=180.0/pi;

niceplot=1;

ncid = netcdf.open(grdname, 'NC_NOWRITE');
rlon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
rlat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
rmask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'))).';
rangle=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'))).';
netcdf.close(ncid);
[M,L]=size(rlat);

ncid = netcdf.open(frcname, 'NC_NOWRITE');
% record k of tide_*(tide_period,eta,xi): start [0 0 k-1], count [L M 1], transposed to (eta,xi)
tide_Eamp=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'tide_Eamp'),[0 0 k-1],[L M 1])).';
tide_Cmax=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'tide_Cmax'),[0 0 k-1],[L M 1])).';
tide_Cmin=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'tide_Cmin'),[0 0 k-1],[L M 1])).';
tide_Cangle=rad*double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'tide_Cangle'),[0 0 k-1],[L M 1])).';
% currents are plotted on a subsampled grid (every skp points)
tide_Cmax=tide_Cmax(1:skp:M,1:skp:L);
tide_Cmin=tide_Cmin(1:skp:M,1:skp:L);
tide_Cangle=tide_Cangle(1:skp:M,1:skp:L);
cmpt=netcdf.getAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'components');
disp(['Plot tidal component : ',cmpt(3*k-2:3*k)])
netcdf.close(ncid);
slon=rlon(1:skp:M,1:skp:L);
slat=rlat(1:skp:M,1:skp:L);
smask=rmask(1:skp:M,1:skp:L);
rmask(rmask==0)=NaN;

disp(['Max currents: ',num2str(max(max(tide_Cmax)),2),' m/s'])

if niceplot==1

  domaxis=[min(min(rlon)) max(max(rlon)) min(min(rlat)) max(max(rlat))];
  m_proj('mercator',...
         'lon',[domaxis(1) domaxis(2)],...
         'lat',[domaxis(3) domaxis(4)]);
  m_pcolor(rlon,rlat,rmask.*tide_Eamp)
  shading flat
  colorbar
  hold on
  oct_m_ellipse(cff*smask.*tide_Cmax,cff*smask.*tide_Cmin,...
           smask.*tide_Cangle,slon,slat,'k');
  if ~isempty(coastfileplot)
    m_usercoast(coastfileplot,'patch',[.9 .9 .9]);
  end
  hold off
  title(['Amplitude [m] of tide : ',cmpt(3*k-2:3*k)])
  m_grid('box','fancy',...
         'xtick',5,'ytick',5,'tickdir','out',...
         'fontsize',7);

else

  pcolor(rlon,rlat,rmask.*tide_Eamp)
  shading flat
  colorbar
  hold on
  oct_ellipse(cff*smask.*tide_Cmax,cff*smask.*tide_Cmin,smask.*tide_Cangle,slon,slat,'k');
  axis([min(min(rlon)) max(max(rlon)) min(min(rlat)) max(max(rlat))])
  title(['Amplitude [m] of tide : ',cmpt(3*k-2:3*k)])
  hold off

end

