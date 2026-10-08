function waitfor(h)
% test stub: screenshot, then press Exit
drawnow; pause(1); system('import -window root EM/em_makegrid.png');
S=guidata(h); printf('[stub waitfor] coast points: %d\n',sum(~isnan(S.xcst)));
cb=get(S.hbut(7),'Callback'); cb(S.hbut(7),[]);
