oct_start; graphics_toolkit qt
addpath([fileparts(mfilename('fullpath')),'/../nesting/stubs']);
global UIFILES CLICKS
H=[pwd,'/CROCO_FILES/croco_his.nc'];
mkdir('VIZ'); cd VIZ
fig=oct_croco_gui(H);
h=guidata(fig);
function cb(fig,tag,val)
  o=findobj(fig,'Tag',tag);
  if nargin>2
    if ischar(val), set(o,'String',val); else, set(o,'Value',val); end
  end
  f=get(o,'Callback'); f{1}(o,[],f{2:end});
  drawnow;
end
function shot(name)
  drawnow; pause(0.5); system(['import -window root ',name,'.png']);
end
printf('vars: %s\n',strjoin(get(h.listvar,'String'),' '));
shot('gui_zeta');
% temp at -10 m with vectors
lst=get(h.listvar,'String'); cb(fig,'listvar',find(strcmp(lst,'temp')));
cb(fig,'editcstep','2');
shot('gui_temp_vec');
% time index up, s-level, contourf
cb(fig,'uptindex'); cb(fig,'editvlev','20'); cb(fig,'contourf');
h=guidata(fig); printf('tindex=%d vlevel=%d pltstyle=%d\n',h.tindex,h.vlevel,h.pltstyle);
% derived: vorticity, gray contours
dl=get(h.listdvar,'String'); cb(fig,'listdvar',find(strcmp(dl,'*Vort'))); cb(fig,'pushbutton30');
cb(fig,'pcolor'); cb(fig,'editcstep','-1');
shot('gui_vort_stream');
cb(fig,'editcstep','0');
% colors and levels
cb(fig,'editcolmin','-2e-6'); cb(fig,'editcolmax','2e-6'); cb(fig,'upncol'); cb(fig,'pushbutton25');
% zoom and limits
cb(fig,'zoom_in'); cb(fig,'uplonmin'); cb(fig,'zoom_out'); cb(fig,'editlatmax','-27');
% boundary points, isobaths, coef
cb(fig,'editnptsW','3'); cb(fig,'editisobath','200 1000'); cb(fig,'editcoef','1e6');
% coast file and towns off
UIFILES={[pwd,'/../coastline_l.mat']}; cb(fig,'coastfile');
lst=get(h.listvar,'String'); cb(fig,'listvar',find(strcmp(lst,'salt')));
cb(fig,'edit_Yorig','2000');
shot('gui_salt_coast');
% Hold / plot
cb(fig,'holdplot'); cb(fig,'uptindex'); cb(fig,'plotbutton');
% view topography (menu)
cb(fig,'viewtopo');
% separate plot and print
lst=get(h.listvar,'String'); cb(fig,'listvar',find(strcmp(lst,'temp'))); cb(fig,'editvlev','-50');
cb(fig,'buttonplot'); cb(fig,'print');
% mouse tools on the map (m_map coordinates of the GUI axes)
h=guidata(fig);
m_proj('mercator','lon',[h.lonmin h.lonmax],'lat',[h.latmin h.latmax]);
[x1,y1]=m_ll2xy(10,-33); [x2,y2]=m_ll2xy(19,-31);
CLICKS=[x1 y1; x2 y2]; cb(fig,'vsection'); print(1,'-dpng','-r70','gui_vsection.png');
CLICKS=[x1 y1; x2 y2]; cb(fig,'hovmull'); print(1,'-dpng','-r70','gui_hovmuller.png');
[x0,y0]=m_ll2xy(15,-32);
CLICKS=[x0 y0]; cb(fig,'tseries'); print(1,'-dpng','-r70','gui_tseries.png');
CLICKS=[x0 y0]; cb(fig,'vprofile'); print(1,'-dpng','-r70','gui_vprofile.png');
% animation every 2 records
cb(fig,'editskipanim','2'); cb(fig,'animation');
% reset
cb(fig,'update');
set(0,'currentfigure',fig); shot('gui_final');
ls
disp('CROCO_GUI FLOW OK')
