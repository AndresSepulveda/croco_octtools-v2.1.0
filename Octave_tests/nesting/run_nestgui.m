oct_start
addpath([fileparts(mfilename('fullpath')),'/stubs'])     % test stubs for dialogs and mouse clicks
graphics_toolkit qt
global UIFILES CLICKS
C=[pwd,'/CROCO_FILES/'];
fig=oct_nestgui([C,'croco_grd.nc']);
h=guidata(fig);
% 1: Define child with two "mouse clicks" (map coordinates of 2 lon/lat corners)
[x1,y1]=m_ll2xy(11.2,-36.0); [x2,y2]=m_ll2xy(16.1,-32.2);
CLICKS=[x1 y1; x2 y2];
oct_nestgui('findgridpos_Callback',fig,[],guidata(fig)); h=guidata(fig);
disp(['child position: ',num2str([h.imin h.imax h.jmin h.jmax])])
% river click
[xr,yr]=m_ll2xy(14.0,-34.0); CLICKS=[xr yr];
oct_nestgui('addriver_Callback',fig,[],guidata(fig)); h=guidata(fig);
disp(['river parent/child: ',num2str([h.Isrcparent h.Jsrcparent h.Isrcchild h.Jsrcchild])])
% New topo on (topo file dialog)
crocotools_param;
UIFILES={topofile};
set(h.newtopo_button,'Value',1); oct_nestgui('newtopo_Callback',fig,[],guidata(fig));
set(h.matchvolume_button,'Value',1); oct_nestgui('matchvolume_Callback',fig,[],guidata(fig));
% 2: Interp child
oct_nestgui('interpchild_Callback',fig,[],guidata(fig));
set(0,'currentfigure',fig); drawnow; pause(1); system('import -window root gui2.png');
% 3: forcing, bulk ; 4: initial, restart ; clim
UIFILES={[C,'croco_frc.nc']}; oct_nestgui('interpforcing_Callback',fig,[],guidata(fig));
UIFILES={[C,'croco_blk.nc']}; oct_nestgui('interpbulk_Callback',fig,[],guidata(fig));
UIFILES={[C,'croco_ini.nc']}; oct_nestgui('interpinitial_Callback',fig,[],guidata(fig));
UIFILES={[C,'croco_rst.nc']}; oct_nestgui('interprestart_Callback',fig,[],guidata(fig));
UIFILES={[C,'croco_clm.nc']}; oct_nestgui('interpclim_Callback',fig,[],guidata(fig));
drawnow; system('import -window root gui3.png');
figure(1); drawnow; print('-dpng','nest_child_grid.png');
disp('GUI FLOW OK')
