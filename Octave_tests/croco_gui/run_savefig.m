oct_start; graphics_toolkit qt
addpath([fileparts(mfilename('fullpath')),'/../nesting/stubs']);
global UIFILES CLICKS
H=[pwd,'/CROCO_FILES/croco_his.nc'];
mkdir('VIZ'); cd VIZ; delete('vsection_*'); delete('mysec*');
fig=oct_croco_gui(H);
function cb(o,val)
  if nargin>1
    if ischar(val), set(o,'String',val); else, set(o,'Value',val); end
  end
  f=get(o,'Callback'); if iscell(f), f{1}(o,[],f{2:end}); else, f(o,[]); end
  drawnow;
end
h=guidata(fig); lst=get(h.listvar,'String'); cb(findobj(fig,'Tag','listvar'),find(strcmp(lst,'temp')));
cb(findobj(fig,'Tag','edittindex'),'3');
h=guidata(fig);
m_proj('mercator','lon',[h.lonmin h.lonmax],'lat',[h.latmin h.latmax]);
[x1,y1]=m_ll2xy(10,-33); [x2,y2]=m_ll2xy(19,-31);
CLICKS=[x1 y1; x2 y2]; cb(findobj(fig,'Tag','vsection'));
% File > Save As... of figure 1
m=findall(1,'type','uimenu','label','Save &As...');
f=get(m,'menuselectedfcn'); f(m,[]); drawnow;
dlg=findall(0,'tag','oct_savefig'); S=guidata(dlg);
printf('suggested: %s\n',get(S.name,'String'));
F=get(S.fmt,'String');
for fmt={'PDF','Encapsulated','Scalable','JPEG','Octave','PNG'}
  k=find(strncmp(F,fmt{1},numel(fmt{1})));
  cb(S.fmt,k); printf('format %-28s -> %s  (dpi %s)\n',F{k},get(S.name,'String'),get(S.dpi,'Enable'));
end
cb(S.name,'mysection.svg'); printf('typed mysection.svg -> format %s\n',F{get(S.fmt,'Value')});
cb(S.fmt,find(strncmp(F,'PDF',3))); printf('then PDF -> %s\n',get(S.name,'String'));
drawnow; pause(0.5); system('import -window root save_dialog.png');
set(S.dir,'String',pwd);
b=findall(dlg,'string','Save'); f=get(b,'Callback'); f(b,[]);
system('file mysection.pdf');
% second time: last format remembered (PDF)
f=get(m,'menuselectedfcn'); f(m,[]); drawnow;
dlg=findall(0,'tag','oct_savefig'); S=guidata(dlg); printf('second suggestion: %s\n',get(S.name,'String'));
cb(S.fmt,find(strncmp(F,'PNG',3))); b=findall(dlg,'string','Save'); f=get(b,'Callback'); f(b,[]);
system('ls -la vsection_temp_t3.png; file vsection_temp_t3.png');
% direct use of oct_vertslice (outside the GUI): title-based name
figure(2); clf; oct_vertslice(H,'',[9 20],[-33 -33],'salt',2);
m2=findall(2,'type','uimenu','label','Save &As...'); f=get(m2,'menuselectedfcn'); f(m2,[]); drawnow;
dlg=findall(0,'tag','oct_savefig'); S=guidata(dlg); printf('direct vertslice suggestion: %s\n',get(S.name,'String'));
delete(dlg);
disp('SAVE TEST OK')
