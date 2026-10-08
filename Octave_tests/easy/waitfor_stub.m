function waitfor(h)
% test stub: press "Apply" in the Easy window
hd=guidata(h); disp('[stub waitfor] Apply');
f=get(hd.pushbutton4,'Callback'); f{1}(hd.pushbutton4,[],f{2:end});
