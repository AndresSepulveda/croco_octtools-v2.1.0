function oct_horizslice(hisfile,vname,tindex,vlevel,rempts,coef,gridlevs,...
                    colmin,colmax,lonmin,lonmax,latmin,latmax,...
                    ncol,pltstyle,isobath,cstep,cscale,cunit,...
                    coastfile,townfile,gridfile,h0,handles,Yorig)
% OCT_HORIZSLICE: procedural NetCDF variant of horizslice using octave-netcdf
refine_coeff=3;
fontsize=10;
width=1;
height=0.8;
% Defaults
if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  vname='temp';
end
if nargin < 3
  tindex=1;
end
if nargin < 4
  vlevel= -10;
end
if nargin < 5
  rempts=[0 0 0 0];
end
if nargin < 6
  coef=1;
end
if nargin < 7
  gridlevs=0;
end
if nargin < 8
  colmin=[]; colmax=[];
end
if nargin < 10
  lonmin=[]; lonmax=[];
end
if nargin < 12
  latmin=[]; latmax=[];
end
if nargin < 14
  ncol=10;
end
if nargin < 15
  pltstyle=1;
end
if nargin < 16
  isobath='100 100';
end
if nargin < 17
  cstep=0; cscale=1; cunit=0.1;
end
if nargin < 20
  coastfile=[]; townfile=[];
end
if nargin < 22
  gridfile=hisfile;
end
if nargin < 23
  h0=[]; handles=[];
end
if nargin < 25
  Yorig=NaN;
end

% Figure handling
if ~isempty(h0)
  set(handles.figure1,'HandleVisibility','on'); set(0,'CurrentFigure',handles.figure1); set(handles.figure1,'CurrentAxes',handles.axes1);
  cla
end

% Read parent data using oct_get_var
[lat,lon,mask,var]=oct_get_var(hisfile,gridfile,vname,tindex,...
                           vlevel,coef,rempts);

% Domain defaults
if isempty(lonmin), lonmin=min(min(lon)); end
if isempty(lonmax), lonmax=max(max(lon)); end
if isempty(latmin), latmin=min(min(lat)); end
if isempty(latmax), latmax=max(max(lat)); end

% Get the date
[day,month,year,imonth,thedate]=oct_get_date(hisfile,tindex,Yorig);

% Color values
maxvar=max(max(var)); minvar=min(min(var));
if isnan(maxvar)||isnan(minvar), maxvar=0; minvar=0; end
if isempty(colmin) || colmin>=colmax
  colmin=minvar; if ~isempty(h0), handles.colmin=colmin; set(handles.editcolmin,'String',num2str(handles.colmin,3)); end
end
if isempty(colmax) || colmin>=colmax
  colmax=maxvar; if ~isempty(h0), handles.colmax=colmax; set(handles.editcolmax,'String',num2str(handles.colmax,3)); end
end
if ~isempty(h0), guidata(h0,handles); end

% Colorbar (external plot case)
if isempty(h0)
  if (pltstyle==1 || pltstyle==2) && maxvar>minvar
    if cstep~=0, oct_fixcolorbar([0.25 0.05 0.35 0.03],[colmin colmax],vname,fontsize)
    else oct_fixcolorbar([0.25 0.05 0.5 0.03],[colmin colmax],vname,fontsize); end
  end
  if pltstyle==5
    if cstep~=0, oct_seawifscolorbar([0.25 0.05 0.35 0.03],vname,fontsize)
    else oct_seawifscolorbar([0.25 0.05 0.5 0.03],vname,fontsize); end
  end
end

% Plot setup
if isempty(h0), subplot('position',[0. 0.14 width height]); end
m_proj('mercator','lon',[lonmin lonmax],'lat',[latmin latmax]);

% Do the plot (reuse oct_do_plot)
oct_do_plot(lon,lat,var,maxvar,minvar,pltstyle,colmin,colmax,ncol,isobath,hisfile,gridfile,tindex,vlevel,cstep,rempts,cscale)

% Embedded levels
for grid_lev=1:gridlevs
  hold on
  chisfile=[hisfile,'.',num2str(grid_lev)];
  cgridfile=[gridfile,'.',num2str(grid_lev)];
  [lat,lon,mask,var]=oct_get_var(chisfile,cgridfile,vname,tindex,vlevel,coef,[0 0 0 0]);
  cstep=cstep*refine_coeff;
  oct_do_plot(lon,lat,var,maxvar,minvar,pltstyle,colmin,colmax,ncol,isobath,chisfile,cgridfile,tindex,vlevel,cstep,rempts,cscale)
  h=oct_bounddomain(lon,lat); set(h,'color','black'); hold off
end

% Coast and towns
if ~isempty(coastfile), hold on; m_usercoast(coastfile,'patch',[.9 .9 .9]); hold off; end
if ~isempty(townfile), oct_add_towns(townfile,10,lonmin,lonmax,latmin,latmax); end

% Grid and title
m_grid('box','fancy','tickdir','in'); set(findobj('tag','m_grid_color'),'facecolor','white')
if isempty(h0), title([vname,' - ',thedate]); else set(handles.edittitle,'String',[vname,' - ',thedate]); set(handles.editdate,'String',thedate); guidata(h0,handles); end

if isempty(h0) && cstep~=0, oct_add_arrow(lonmin,lonmax,latmin,latmax,cunit,cscale,width,height); end

% Colorbar for GUI
if ~isempty(h0)
  if pltstyle<3 && maxvar>minvar
    set(handles.figure1,'HandleVisibility','on'); set(0,'CurrentFigure',handles.figure1); set(handles.figure1,'CurrentAxes',handles.axes2);
    dc=(colmax-colmin)/ncol; x=[0:1]; y=[colmin:dc:colmax]; [X,Y]=meshgrid(x,y);
    if pltstyle==1, pcolor(X,Y,Y); elseif pltstyle==2, contourf(X,Y,Y,[colmin:dc:colmax]); end
    shading flat; caxis([colmin colmax]); set(gca,'YAxisLocation','right','Xtick',[],'Visible','on')
  elseif pltstyle==5
    set(handles.figure1,'HandleVisibility','on'); set(0,'CurrentFigure',handles.figure1); set(handles.figure1,'CurrentAxes',handles.axes2); x=[0:1]; y=[0:70]; [X,Y]=meshgrid(x,y); pcolor(X,Y,Y)
    L = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50]; l=(log10(L)+2)*70/(log10(70)+2); set(gca,'YTick',l,'YTickLabel',L); set(gca,'YAxisLocation','right','Xtick',[],'Visible','on'); shading flat; caxis([0.01 70])
  else
    set(handles.figure1,'HandleVisibility','on'); set(0,'CurrentFigure',handles.figure1); set(handles.figure1,'CurrentAxes',handles.axes2); cla; set(gca,'Visible','off')
  end
end

if isempty(h0), oct_savefig('install',gcf); end   % File > Save (As): extension follows the format
return
