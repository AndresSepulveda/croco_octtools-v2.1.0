function y = oct_getframe_fli(frame_num,fid)

% function y = oct_getframe_fli(frame_num,fid)
if frame_num<10
  strnum=['00',num2str(frame_num)];
elseif frame_num<100
  strnum=['0',num2str(frame_num)];
else frame_num<100
  strnum=[num2str(frame_num)];
end
eval(['print -painter -depsc2 ',strnum,'.eps;'])
system([' convert -density 80 ',strnum,'.eps ',strnum,'.ppm'])
system([' rm -f ',strnum,'.eps'])
eval(['fprintf(fid,''',strnum,'.ppm\n'');'])
