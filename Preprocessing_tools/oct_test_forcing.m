function oct_test_forcing(frcname,grdname,thefield,thetime,skip,coastfileplot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot a variable from the forcing file 
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    31-Aug-2006 by Pierrick Penven
%  Updated    25-Oct-2006 by Pierrick Penven (uwnd and vwnd)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
isoctave=(exist('OCTAVE_VERSION','builtin')~=0);
niceplot=1;
i=0;
for time=thetime
  i=i+1;
  
  subplot(2,length(thetime)/2,i)

  ncid = netcdf.open(frcname, 'NC_NOWRITE');
%
% Forcing (sms_time) or bulk (bulk_time) file ? Record 'time' is read
% with 0-based start and Fortran-order count, then transposed to (eta,xi).
%
  try
    tvid=netcdf.inqVarID(ncid, 'sms_time');
    isbulk=0;
  catch
    try
      tvid=netcdf.inqVarID(ncid, 'bulk_time');
      isbulk=1;
    catch
      error('TEST_FORCING: Is it a forcing or a bulk file ?')
    end
  end
  stime=double(netcdf.getVar(ncid, tvid, time-1, 1));
  [~,Lp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
  [~,Mp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
  if isbulk
    uname='uwnd'; vname='vwnd';
    spdname='wind speed'; spdunits='m/s';
  else
    uname='sustr'; vname='svstr';
    spdname='wind stress'; spdunits='N/m^2';
  end
  u=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, uname), [0 0 time-1], [Lp-1 Mp 1])).';
  v=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 time-1], [Lp Mp-1 1])).';
  if thefield(1:3)=='spd'
    field=sqrt((oct_u2rho_2d(u)).^2+(oct_v2rho_2d(v)).^2);
    fieldname=spdname;
    units=spdunits;
  else
    fvid=netcdf.inqVarID(ncid, thefield);
    [~,~,dids]=netcdf.inqVar(ncid, fvid);
    [~,nx]=netcdf.inqDim(ncid, dids(1));
    [~,ny]=netcdf.inqDim(ncid, dids(2));
    field=double(netcdf.getVar(ncid, fvid, [0 0 time-1], [nx ny 1])).';
    fieldname=netcdf.getAtt(ncid, fvid, 'long_name');
    units=netcdf.getAtt(ncid, fvid, 'units');
  end
  netcdf.close(ncid);
%
% Read the grid
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
  if strcmp(thefield,'sustr') | strcmp(thefield,'uwnd')
    lon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_u'))).';
    lat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_u'))).';
    mask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_u'))).';
  elseif strcmp(thefield,'svstr') | strcmp(thefield,'vwnd')
    lon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_v'))).';
    lat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_v'))).';
    mask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_v'))).';
  else
    lon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
    lat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
    mask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'))).';
  end
  angle=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'))).';
  netcdf.close(ncid);
  mask(mask==0)=NaN;
%
% compute the vectors
% 
  [ured,vred,lonred,latred,speed]=oct_uv_vec2rho(u,v,lon,lat,angle,...
                                             mask,skip,[0 0 0 0]);
%
% Make the plot
%  
if (isoctave);
    aux_plot=mask.*squeeze(field);
    aux_field=flipud(aux_plot);
    imagesc(aux_field)
    colorbar
    try 
       title([fieldname',' - day: ',num2str(stime)])
    catch
       title([fieldname,' - day: ',num2str(stime)])
    end
else
  if niceplot==1
    domaxis=[min(min(lon)) max(max(lon)) min(min(lat)) max(max(lat))];
    m_proj('mercator',...
       'lon',[domaxis(1) domaxis(2)],...
       'lat',[domaxis(3) domaxis(4)]);

    m_pcolor(lon,lat,mask.*field);
    shading flat
    drawnow
    hc=colorbar;
    set(get(hc,'label'),'string',units);
    hold on
    m_quiver(lonred,latred,ured,vred,'k');
    if ~isempty(coastfileplot)
      m_usercoast(coastfileplot,'patch',[.9 .9 .9]);
    end
    hold off
    title([fieldname,' - day: ',num2str(stime)])
    m_grid('box','fancy',...
           'xtick',5,'ytick',5,'tickdir','out',...
           'fontsize',7);
  else
    imagesc(mask.*field)
    title([fieldname,' - day: ',num2str(stime)])
  end
end
end

